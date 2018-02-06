module Towhee::Blog
  class Site
    def initialize(name:)
      @name = name
    end

    attr_reader :name
  end
end
