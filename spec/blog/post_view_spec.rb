require 'towhee/blog/post_view'
require 'towhee/blog/layout'
require 'towhee/blog/site'
require 'towhee/blog/post'
require 'towhee/blog/category'

RSpec.describe Towhee::Blog::PostView do
  let(:site) { Towhee::Blog::Site.new(name: "Some Site") }
  let(:view) do
    described_class.new(
      site: site,
      post: post,
      recent: recent_posts,
      category_summary: category_summary,
      layout: Towhee::Blog::Layout,
    )
  end
  let(:post) do
    Towhee::Blog::Post.new(
      title: "Some Post",
      slug: "some-post",
      body: "<p>Post body.</p>\n<p>More post body.</p>",
    )
  end
  let(:recent_posts) { [] }
  let(:category_summary) { [] }

  it "has permalink path" do
    expect(view.path).to eq "posts/some-post.html"
  end

  it "renders title with post title and site name" do
    expect(view.render).to match /Some Post - Some Site/
  end

  it "renders header with post title" do
    expect(view.render).to match %r{<h1>\s*Some Post\s*</h1>}m
  end

  it "renders post body unescaped" do
    expect(view.render).to match %r{<p>Post body.</p>}
    expect(view.render).to match %r{<p>More post body.</p>}
  end

  it "recent posts unavailable" do
    expect(view.render).to match %r{<h1>\s*Recent Posts\s*</h1>}
    expect(view.render).to match %r{<p>\s*No other recent posts.\s*</p>}
  end

  it "category summary unavailable" do
    expect(view.render).to match %r{<h1>\s*Categories\s*</h1>}
    expect(view.render).to match %r{<p>\s*No categories yet.\s*</p>}
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

  context "categories present" do
    let(:category_summary) { { category => "the count" } }
    let(:category) do
      Towhee::Blog::Category.new(
        name: "The Category",
        slug: "the-category",
      )
    end

    it "links to categories" do
      expect(view.render).to match %r{<h1>\s*Categories\s*</h1>}
      expect(view.render).to match %r{<li>\s*<a[^>]*>The Category</a> \(}
      expect(view.render).to match \
        %r{<a\s*href="/categories/the-category.html">The Category}
      expect(view.render).to match "(the count)"
    end
  end
end
