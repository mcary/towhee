module Towhee::HTML
  module TagDefiner
    def define_inline_tag(name)
      # See this post for a discussion of the merits of define_method
      # vs class_eval with def.  define_method runs slightly slower, but
      # it boots faster and uses less memory.
      # https://tenderlovemaking.com/2013/03/03/dynamic_method_definitions.html
      # In this case, we may have added overhead from creating a proc from
      # a block in the define_method implementation.
      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{name}(*args)
          inline_tag("#{name}", *args) { yield }
        end
      EOS
    end

    def define_block_tag(name)
      # See performance comment in define_inline_tag.
      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{name}(*args)
          block_tag("#{name}", *args) { yield }
        end
      EOS
    end

    private :define_inline_tag, :define_block_tag
  end
end
