module Towhee::HTML
  module TagDefiner
    def define_inline_tag(name)
      # See tag_definer_benchmark to compare alternative implementations.
      # I'm not seeing a consistent winner.
      name_str = name.to_s
      define_method(name) do |*args, &block|
        inline_tag(name_str, *args, &block)
      end
    end

    def define_block_tag(name)
      # See performance comment in define_inline_tag.
      name_str = name.to_s
      define_method(name) do |*args, &block|
        block_tag(name_str, *args, &block)
      end
    end

    private :define_inline_tag, :define_block_tag
  end
end
