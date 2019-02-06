require 'towhee/prerender'

module Towhee::Prerender
  class FileSystem
    def initialize(path)
      @root = path
    end

    def []=(file_path, contents)
      full_path = "#@root/#{file_path}"
      ensure_parent_dir(full_path)
      File.open(full_path, "w") do |f|
        f.write(contents)
      end
    end

    private

    def ensure_parent_dir(full_path)
      dir = File.dirname(full_path)
      Dir.mkdir(dir) unless File.directory?(dir)
    end
  end
end
