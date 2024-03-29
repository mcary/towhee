require 'towhee/blog/home_view'
require 'towhee/blog/layout'
require 'towhee/blog/site'
require 'towhee/blog/post'

RSpec.describe Towhee::Blog::HomeView do
  let(:site) { Towhee::Blog::Site.new(name: "Some Site") }

  context "with no posts" do
    let(:view) do
      described_class.new(
        site: site,
        posts: [],
        layout: Towhee::Blog::Layout,
      )
    end

    it "has root path" do
      expect(view.path).to eq "index.html"
    end

    it "renders title with site name and no joining punctuation" do
      expect(view.render).to match /<title>Some Site</
    end

    it "renders site name" do
      expect(view.render).to match /Some Site Home/
    end

    it "links to stylesheet" do
      expect(view.render).to match /<link rel="stylesheet".*href="main.css"/
    end

    it "renders empty message" do
      expect(view.render).to match /No posts yet./
    end
  end

  context "with a post" do
    let(:posts) { [Towhee::Blog::Post.new(title: "Some Post", slug: "aslug" )] }
    let(:view) do
      described_class.new(
        site: site,
        posts: posts,
        layout: Towhee::Blog::Layout,
      )
    end

    it "renders posts" do
      expect(view.render).to match /Some Post/
    end

    it "renders posts without escaping <li> tags" do
      expect(view.render).to match /<li>\s*<a[^<>]*>Some Post/m
    end

    it "links post to post page" do
      expect(view.render).to match %{<a href="/posts/aslug.html"}
    end
  end
end
