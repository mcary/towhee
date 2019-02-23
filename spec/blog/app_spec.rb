require 'towhee/prerender/memory_file_system'
require 'towhee/blog/app'
require 'towhee/blog/site'
require 'towhee/blog/post'
require 'towhee/blog/category'
require 'towhee/blog/repository'

RSpec.describe "Blog prerendering" do
  subject do
    repo = Towhee::Blog::Repository.new(
      site_hash: {
        Towhee::Blog::Site.new(name: "Foo") => [post],
      },
      category_hash: {
        category => [post],
      },
    )
    Towhee::Blog::App.new(fs: file_system, repo: repo)
  end

  let(:file_system) { Towhee::Prerender::MemoryFileSystem.new }

  let(:post) do
    Towhee::Blog::Post.new(
      title: "Title",
      slug: "slug",
      body: "<p>Body",
    )
  end

  let(:category) do
    Towhee::Blog::Category.new(name: "Cat", slug: "cat", description: "Blarg")
  end

  it "prerenders" do
    benchmark "blog prerender" do
      subject.prerender
    end
    expect(file_system.files).to include("index.html" => /Home/)
    expect(file_system.files).to include("posts/slug.html" => /Title - Foo/)
    expect(file_system.files).to include("categories/cat.html" => /Cat - Foo/)
  end
end
