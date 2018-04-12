module Towhee::Blog
  class Post
    def initialize(title:, slug: "", body: "")
      @title = title
      @slug = slug
      @body = body
    end

    attr_reader :title
    attr_reader :slug
    attr_reader :body
  end
end

