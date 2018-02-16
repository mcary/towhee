require 'towhee/prerender/file_system'
require 'fileutils'

RSpec.describe Towhee::Prerender::FileSystem do
  subject do
    described_class.new(fs_root)
  end

  let :fs_root do
    project_root = File.dirname(File.dirname(File.dirname(__FILE__)))
    project_root + "/tmp/test-fs"
  end

  it "saves files" do
    FileUtils.rm_rf(fs_root)
    Dir.mkdir(fs_root)
    subject["foo.html"] = "bar\n"
    expect(File.read(fs_root + "/foo.html")).to eq "bar\n"
  end
end

