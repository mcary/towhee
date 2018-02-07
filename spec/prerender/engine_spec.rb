require 'towhee/prerender/engine'

RSpec.describe "Prerender Engine" do
  let(:file_system) { double(:file_system) }
  let(:engine) do
    Towhee::Prerender::Engine.new(
      fs: file_system,
      view_enumerator: TestViewEnumerator.new,
    )
  end

  it "renders post 1" do
    post = double(:post, id: 1, content: "content", categories: [])
    expect(file_system).to receive(:[]=).
      with("post-1.html", "<html>content</html>")
    engine.changed(post)
  end

  it "renders post 2" do
    post = double(:post, id: 2, content: "other content", categories: [
      double(:category, id: 1, name: "Tech"),
    ])
    expect(file_system).to receive(:[]=).
      with("post-2.html", "<html>other content</html>")
    expect(file_system).to receive(:[]=).
      with("category-1.html", "<html>Tech</html>")
    engine.changed(post)
  end

  it "renders category" do
    category = double(:category, id: 1, name: "Tech")
    expect(file_system).to receive(:[]=).
      with("category-1.html", "<html>Tech</html>")
    engine.changed(category)
  end

  it "deduplicates views" do
    category = double(:category, id: 1, name: "Tech")
    post = double(:post, id: 2, content: "other content", categories: [
      category,
    ])
    expect(file_system).to receive(:[]=).
      with("category-1.html", "<html>Tech</html>").once
    allow(file_system).to receive(:[]=).
      with("post-2.html", "<html>other content</html>")
    engine.batch_changed([category, post])
  end

  class TestViewEnumerator
    def views_for_model(model)
      if model.respond_to? :content
        category_views = model.categories.flat_map {|c| views_for_model(c) }
        [TestPostView.new(model), *category_views]
      else
        [TestCategoryView.new(model)]
      end
    end
  end

  class TestPostView
    def initialize(post)
      @post = post
    end

    def path
      "post-#{@post.id}.html"
    end

    def render
      "<html>#{@post.content}</html>"
    end

    def key
      [:post, @post.id]
    end
  end

  class TestCategoryView
    def initialize(category)
      @category = category
    end

    def path
      "category-#{@category.id}.html"
    end

    def render
      "<html>#{@category.name}</html>"
    end

    def key
      [:category, @category.id]
    end
  end
end
