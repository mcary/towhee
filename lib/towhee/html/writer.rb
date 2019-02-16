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
    define_block_tag :html
    define_block_tag :head
    define_block_tag :body
    define_block_tag :ul
    define_block_tag :li
    define_inline_tag :a
    (0..6).each { |n| define_block_tag "h#{n}".to_sym }
    define_block_tag :aside
    define_block_tag :section
    define_block_tag :header

    def br
      follow_with_newline(empty_tag("br"))
    end

    def title(*args)
      follow_with_newline(inline_tag("title", *args) { yield })
    end

    def link(*args)
      follow_with_newline(empty_tag("link", *args))
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

    def meta(*args)
      follow_with_newline(empty_tag("meta", *args))
    end

    def text(str)
      escape(str)
    end

    def trust(str)
      Fragment.new(str)
    end

    def join_fragments(fragments)
      fragments.inject(Towhee::HTML::Fragment.new(""), &:+)
    end

    private

    def block_tag(tag_name, attributes={})
      child_content = increasing_indent do
        child_content = yield
        child_content = if false || child_content
          "\n#{prefix}#{escape(child_content)}"
        end
        child_content = child_content.to_s
      end
      suffix = "\n#{prefix}"
      child_content += suffix unless child_content.end_with?(suffix)
      open_tag = "<#{tag_name}#{attr_str(attributes)}>"
      trust "#{open_tag}#{child_content}</#{tag_name}>\n#{prefix}"
    end

    def inline_tag(tag_name, attributes={})
      trust "<#{tag_name}#{attr_str(attributes)}>#{escape yield}</#{tag_name}>"
    end

    def empty_tag(tag_name, attributes={})
      trust "<#{tag_name}#{attr_str(attributes)} />"
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
  end
end
