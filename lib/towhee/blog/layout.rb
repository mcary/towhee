require 'towhee'
require 'towhee/html/writer'

module Towhee::Blog
  class Layout
    def initialize(title:, main:, sidebar_modules:)
      @title = title
      @main = main
      @sidebar_modules = sidebar_modules
      @html = Towhee::HTML::Writer.new
    end

    def render
      @html.html do
        @html.head do
          @html.title { @title }
        end +
          @html.body do
            main_column + sidebar_column
          end
      end.to_s
    end

    private

    def main_column
      @main
    end

    def sidebar_column
      @html.aside do
        @html.join_fragments(
          @sidebar_modules.map do |mod| 
            @html.section do
              mod
            end
          end
        )
      end
    end
  end
end

