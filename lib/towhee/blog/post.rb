module Towhee::Blog
  class Post
    def initialize(title:)
      @title = title
    end

    attr_reader :title
  end
end

