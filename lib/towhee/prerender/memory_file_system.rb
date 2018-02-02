require 'towhee/prerender'

module Towhee::Prerender
  class MemoryFileSystem
    def initialize
      @files = {}
    end

    def []=(file_path, contents)
      @files[file_path] = contents
    end

    def files
      @files.dup
    end
  end
end
