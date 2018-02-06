require 'towhee/blog/home_view'

RSpec.describe "Blog HomeView" do
  it "renders" do
    site = double(:site, name: "SomeSite")
    view = Towhee::Blog::HomeView.new(site)
    expect(view.render).to match /SomeSite Home/
  end
end
