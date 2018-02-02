require 'towhee/prerender'

module Towhee::Prerender
  class FileSystem
    def initialize(path)
      @root = path
    end

    def []=(file_path, contents)
      File.open("#@root/#{file_path}", "w") do |f|
        f.write(contents)
      end
    end
  end
end
