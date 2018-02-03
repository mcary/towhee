require 'towhee/prerender/memory_file_system'
require 'towhee/blog/app'

RSpec.describe "Blog prerendering" do
  it "prerenders" do
    file_system = Towhee::Prerender::MemoryFileSystem.new
    benchmark "blog prerender" do
      Towhee::Blog::App.new.prerender(file_system)
    end
    expect(file_system.files).to include("index.html" => /Home/)
  end
end
