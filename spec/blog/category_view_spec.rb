require 'towhee/blog/category_view'
require 'towhee/blog/layout'
require 'towhee/blog/site'
require 'towhee/blog/post'
require 'towhee/blog/category'

RSpec.describe Towhee::Blog::CategoryView do
  let(:site) { Towhee::Blog::Site.new(name: "Some Site") }
  let(:view) do
    described_class.new(
      site: site,
      category: category,
      posts: posts,
      recent: recent_posts,
      layout: Towhee::Blog::Layout,
    )
  end
  let(:category) do
    Towhee::Blog::Category.new(
      name: "The Category",
      slug: "cat",
      description: "<p>All about the category</p>",
    )
  end
  let(:posts) { [] }
  let(:recent_posts) { [] }

  context "with posts" do
    it "has permalink path" do
      expect(view.path).to eq "categories/cat.html"
    end

    it "renders title with category name and site name" do
      expect(view.render).to match /The Category - Some Site/
    end

    it "renders header with category name" do
      expect(view.render).to match %r{<h1>\s*The Category\s*</h1>}m
    end

    it "renders description unescaped" do
      expect(view.render).to match %r{<p>All about the category</p>}
    end

    it "renders empty message" do
      expect(view.render).to match /No posts yet./
    end

    it "recent posts unavailable" do
      expect(view.render).to match %r{<h1>\s*Recent Posts\s*</h1>}
      expect(view.render).to match %r{<p>\s*No other recent posts.\s*</p>}
    end

    context "recent posts present" do
      let(:recent_posts) { [recent_post] }
      let(:recent_post) do
        Towhee::Blog::Post.new(
          title: "Recent Post 1",
          slug: "recent-post-1",
        )
      end

      it "links to recent posts" do
        expect(view.render).to match %r{<h1>\s*Recent Posts\s*</h1>}
        expect(view.render).to match %r{<li>\s*<a[^>]*>Recent Post 1</a>\s*</li>}
        expect(view.render).to match \
          %r{<a\s*href="/posts/recent-post-1.html">Recent Post 1}
      end
    end
  end

  context "with a post" do
    let(:posts) { [post] }
    let(:post) do
      Towhee::Blog::Post.new(
        title: "Some Post",
        slug: "some-post",
        body: "<p>Post body.</p>\n<p>More post body.</p>",
      )
    end

    it "renders posts" do
      expect(view.render).to match /Some Post/
    end
  end
end
