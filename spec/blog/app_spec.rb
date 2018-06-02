require 'towhee/prerender/memory_file_system'
require 'towhee/blog/app'
require 'towhee/blog/site'
require 'towhee/blog/post'
require 'towhee/blog/repository'

RSpec.describe "Blog prerendering" do
  subject do
    repo = Towhee::Blog::Repository.new(
      sites: [Towhee::Blog::Site.new(name: "Foo")],
      posts: [Towhee::Blog::Post.new(
        title: "Title",
        slug: "slug",
        body: "<p>Body",
      )],
    )
    Towhee::Blog::App.new(fs: file_system, repo: repo)
  end

  let(:file_system) { Towhee::Prerender::MemoryFileSystem.new }

  it "prerenders" do
    benchmark "blog prerender" do
      subject.prerender
    end
    expect(file_system.files).to include("index.html" => /Home/)
  end
end
