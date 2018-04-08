require 'towhee/blog/home_view'
require 'towhee/blog/site'
require 'towhee/blog/post'

RSpec.describe Towhee::Blog::HomeView do
  let(:site) { Towhee::Blog::Site.new(name: "Some Site") }

  it "renders site name" do
    view = described_class.new(site)
    expect(view.render).to match /Some Site Home/
  end

  it "renders empty message" do
    view = described_class.new(site)
    expect(view.render).to match /No posts yet./
  end

  it "renders posts" do
    posts = [Towhee::Blog::Post.new(title: "Some Post")]
    view = described_class.new(site, posts: posts)
    expect(view.render).to match /Some Post/
  end

  it "renders posts without escaping <li> tags" do
    posts = [Towhee::Blog::Post.new(title: "Some Post")]
    view = described_class.new(site, posts: posts)
    expect(view.render).to match /<li>\s*Some Post/m
  end
end
