# See this post for a discussion of the merits of define_method
# vs class_eval with def.  define_method runs slightly slower, but
# it boots faster and uses less memory.
# https://tenderlovemaking.com/2013/03/03/dynamic_method_definitions.html
#
# However, I'm not seeing a clear winner among the options below.  This code
# may be unique in its need to pass along a block or proc.
require 'benchmark'
require 'benchmark/memory'
require 'cgi'
require 'towhee/html/fragment'

def main
  flavors = [
    IOWriter,
    IONoIndentWriter,
    ReturningWriter,
    ReturnNoIndentWriter,
  ]

  Benchmark.memory do |x|
    flavors.shuffle.each do |flavor|
      writer = flavor.new
      x.report(flavor.name.sub("Writer", "")) do
        run_with(writer)
        #p writer.get_string if writer.respond_to? :get_string
      end
    end

    x.compare!
  end

  puts
  Benchmark.bm(13) do |x|
    flavors.shuffle.each do |flavor|
      writer = flavor.new
      x.report(flavor.name.sub("Writer", "")) do
        10_000.times { run_with(writer) }
        #p writer.get_string if writer.respond_to? :get_string
      end
    end
  end
end

def run_with(writer)
  writer.div(class: "foo") { writer.div { writer.text "bar" } }
end

include Towhee::HTML

class IOWriter
  def initialize
    @indent = 0
    @io = StringIO.new
  end


  def div(attributes={})
    block_tag("div", attributes) { yield }
  end

  def text(str)
    @io.write escape(str)
  end

  def get_string
    @io.string
  end

  private

  def block_tag(tag_name, attributes={})
    @io.write "<#{tag_name}#{attr_str(attributes)}>"
    increasing_indent do
      prefix
      yield
    end
    @io.write "\n"
    prefix
    @io.write "</#{tag_name}>"
  end

  def increasing_indent
    @indent += 2
    yield
  ensure
    @indent -= 2
  end

  def prefix
    @indent.times { @io.write " " }
  end

  def attr_str(attrs)
    attrs.map do |name, value|
      " #{validate_attr name}=\"#{escape value}\""
    end.join
  end

  def escape(obj)
    CGI::escapeHTML(obj)
  end

  def validate_attr(name)
    raise "Invalid attribute name" if name.match(/[^-_:a-z0-9]/)
    name
  end
end

class IONoIndentWriter
  def initialize
    @indent = 0
    @io = StringIO.new
  end


  def div(attributes={})
    block_tag("div", attributes) { yield }
  end

  def text(str)
    @io.write escape(str)
  end

  def get_string
    @io.string
  end

  private

  def block_tag(tag_name, attributes={})
    @io.write "<#{tag_name}#{attr_str(attributes)}>"
    yield
    @io.write "</#{tag_name}>"
  end

  def attr_str(attrs)
    attrs.map do |name, value|
      " #{validate_attr name}=\"#{escape value}\""
    end.join
  end

  def escape(obj)
    CGI::escapeHTML(obj)
  end

  def validate_attr(name)
    raise "Invalid attribute name" if name.match(/[^-_:a-z0-9]/)
    name
  end
end

class ReturningWriter
  def initialize
    @indent = 0
  end

  def div(attributes={})
    block_tag("div", attributes) { yield }
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

class ReturnNoIndentWriter
  def initialize
    @indent = 0
  end

  def div(attributes={})
    block_tag("div", attributes) { yield }
  end

  def text(str)
    escape(str)
  end

  private

  def block_tag(tag_name, attributes={})
    open_tag = "<#{tag_name}#{attr_str(attributes)}>"
    child_content = escape(yield)
    trust "#{open_tag}#{child_content}</#{tag_name}>"
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

main
