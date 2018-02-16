require 'cgi'
require 'towhee/html'
require 'towhee/html/fragment'
require 'towhee/html/tag_definer'

module Towhee::HTML
  class Writer
    extend TagDefiner

    def initialize
      @indent = 0
    end

    define_inline_tag :span
    define_block_tag :div
    define_block_tag :p
    define_inline_tag :a

    def br
      follow_with_newline(empty_tag("br"))
    end

    def script(*args)
      if block_given?
        block_tag("script", *args) do
          # Javascript won't parse if we escape it.  It has to be trusted.
          trust yield
        end
      else
        # It's not actually inline, but we'd like to see it all on one line.
        follow_with_newline(inline_tag("script", *args) { })
      end
    end

    def style(*args)
      block_tag("style", *args) do
        # CSS won't parse if we escape it.  It has to be trusted.
        trust yield
      end
    end


    def text(str)
      escape(str)
    end

    private

    def block_tag(tag_name, attributes={})
      child_content =
        "#{increasing_indent { trust(prefix) + escape(yield) } }\n#{prefix}"
      open_tag = "<#{tag_name}#{attr_str(attributes)}>"
      trust "#{open_tag}\n#{child_content}</#{tag_name}>"
    end

    def inline_tag(tag_name, attributes={})
      trust "<#{tag_name}#{attr_str(attributes)}>#{escape yield}</#{tag_name}>"
    end

    def empty_tag(tag_name)
      trust "<#{tag_name} />"
    end

    def follow_with_newline(obj)
      obj + trust("\n#{prefix}")
    end

    def increasing_indent
      @indent += 2
      yield
    ensure
      @indent -= 2
    end

    def prefix
      " " * @indent
    end

    def attr_str(attrs)
      attrs.map do |name, value|
        " #{validate_attr name}=\"#{escape value}\""
      end.join
    end

    def escape(obj)
      case obj
      when Fragment then obj
      when String then trust(CGI::escapeHTML(obj))
      when nil then trust("")
      else raise "Unknown type: #{obj.class}"
      end
    end

    def validate_attr(name)
      raise "Invalid attribute name" if name.match(/[^-_:a-z0-9]/)
      name
    end

    def trust(str)
      Fragment.new(str)
    end
  end
end
