require 'towhee/blog/post_view'
require 'towhee/blog/site'
require 'towhee/blog/post'

RSpec.describe Towhee::Blog::PostView do
  let(:site) { Towhee::Blog::Site.new(name: "Some Site") }
  let(:view) { described_class.new(site: site, post: post) }
  let(:post) do
    Towhee::Blog::Post.new(
      title: "Some Post",
      slug: "some-post",
      body: "<p>Post body.</p>\n<p>More post body.</p>",
    )
  end

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
end
