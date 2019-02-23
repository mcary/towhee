module Towhee::Blog
  class Category
    def initialize(name:, slug: "", description: "")
      @name = name
      @slug = slug
      @description = description
    end

    attr_reader :name
    attr_reader :slug
    attr_reader :description
  end
end

