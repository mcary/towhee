require 'towhee/blog/home_view'
require 'towhee/blog/site'

RSpec.describe "Blog HomeView" do
  it "renders" do
    site = Towhee::Blog::Site.new(name: "SomeSite")
    view = Towhee::Blog::HomeView.new(site)
    expect(view.render).to match /SomeSite Home/
  end
end
