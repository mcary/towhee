require 'towhee/html'

module Towhee::HTML
  class Fragment
    def initialize(str)
      @str = str
    end

    def +(other)
      Fragment.new(@str + other.str)
    end

    def to_s
      @str
    end

    protected

    attr_reader :str
  end
end
