require 'towhee/blog/home_view'
require 'towhee/blog/site'
require 'towhee/blog/post'

RSpec.describe "Blog HomeView" do
  let(:site) { Towhee::Blog::Site.new(name: "Some Site") }

  it "renders site name" do
    view = Towhee::Blog::HomeView.new(site)
    expect(view.render).to match /Some Site Home/
  end

  it "renders empty message" do
    view = Towhee::Blog::HomeView.new(site)
    expect(view.render).to match /No posts yet./
  end

  it "renders posts" do
    posts = [Towhee::Blog::Post.new(title: "Some Post")]
    view = Towhee::Blog::HomeView.new(site, posts: posts)
    expect(view.render).to match /Some Post/
  end
end
