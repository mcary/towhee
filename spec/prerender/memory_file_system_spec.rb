require 'towhee/prerender/memory_file_system'

RSpec.describe Towhee::Prerender::MemoryFileSystem do
  it "saves files" do
    subject["foo.html"] = "bar\n"
    expect(subject.files).to eq("foo.html" => "bar\n")
  end
end

