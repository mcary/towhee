require 'towhee/html'

module Towhee::HTML
  class Fragment
    def initialize(str)
      @str = str
    end

    def +(other)
      ensure_not_string!(other)
      Fragment.new(@str + other.fragment_str)
    end

    def to_s
      @str
    end

    protected

    def fragment_str
      @str
    end

    private

    def ensure_not_string!(other)
      if other.is_a? String
        raise TypeError,
          "no implicit conversion of String into Towhee::HTML::Fragment\n" +
            "Call Writer#text for untrusted text or Writer#trust for " +
            "content that you know is clean of malicious markup."
      end
    end
  end
end
