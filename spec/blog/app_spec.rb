require 'towhee/prerender/memory_file_system'
require 'towhee/blog/app'
require 'towhee/blog/site'

RSpec.describe "Blog prerendering" do
  subject do
    repo = Towhee::Blog::Repository.new(
      sites: [Towhee::Blog::Site.new(name: "Foo")],
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
