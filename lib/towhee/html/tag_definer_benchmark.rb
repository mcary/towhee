# See this post for a discussion of the merits of define_method
# vs class_eval with def.  define_method runs slightly slower, but
# it boots faster and uses less memory.
# https://tenderlovemaking.com/2013/03/03/dynamic_method_definitions.html
#
# However, I'm not seeing a clear winner among the options below.  This code
# may be unique in its need to pass along a block or proc.
require 'benchmark'
require 'towhee/html/writer'

N = 100_000

def main
  flavors = [
    DefnMethWriter,
    DefnMethSymWriter,
    DefnMethTosWriter,
    DefnMethStrWriter,
    ClassEvalWriter,
    NoMacroWriter,
  ]

  Benchmark.bm(13) do |x|
    flavors.shuffle.each do |flavor|
      writer = flavor.new
      GC.start
      sleep 1
      GC.disable
      x.report(flavor.name.sub("Writer", "")) do
        run_with(writer)
      end
      GC.enable
    end
  end
end

def run_with(writer)
  N.times { writer.foo { "bar" } }
end


include Towhee::HTML

class DefnMethWriter < Writer
  def self.define_tag(name)
    define_method(name) do |*args, &block|
      block_tag(name, *args, &block)
    end
  end

  define_tag "foo"
end

class DefnMethSymWriter < Writer
  def self.define_tag(name)
    define_method(name) do |*args, &block|
      block_tag(name, *args, &block)
    end
  end

  define_tag :foo
end

class DefnMethTosWriter < Writer
  def self.define_tag(name)
    name_str = name.to_s
    define_method(name) do |*args, &block|
      block_tag(name_str, *args, &block)
    end
  end

  define_tag :foo
end

class DefnMethStrWriter < Writer
  def self.define_tag(name)
    define_method(name) do |*args, &block|
      block_tag(name, *args, &block)
    end
  end

  define_tag "foo"
end

class ClassEvalWriter < Writer
  def self.define_tag(name)
    class_eval <<-EOS, __FILE__, __LINE__ + 1
      def #{name}(*args)
        block_tag("#{name}", *args) { yield }
      end
    EOS
  end

  define_tag "foo"
end

class NoMacroWriter < Writer
  def foo(*args)
    block_tag("foo", *args) { yield }
  end
end

main
