require 'towhee'
require 'towhee/html/writer'

module Towhee::Blog
  class Layout
    def initialize(title:, main:, sidebar_modules:, site: @site)
      @title = title
      @main = main
      @sidebar_modules = sidebar_modules
      @site = site
      @html = Towhee::HTML::Writer.new
    end

    def render
      @html.html do
        head + body
      end.to_s
    end

    private

    def body
      @html.body do
        @html.div class: "container" do
          row(style: "border-bottom: 1px solid black") do
            col(12) { header_content }
          end +
            row do
              col(8) { main_content } +
                col(4) { sidebar_content }
            end
        end
      end
    end

    def row(attributes={})
      @html.div({class: "row"}.merge(attributes)) { yield }
    end

    def col(width)
      @html.div(class: "col-#{width}") { yield }
    end

    def header_content
      @html.h1(class: "display-1") { @site.name }
    end

    def head
      @html.head do
        @html.title { @title } +
          @html.script(src: "main.js") +
          @html.link(rel: "stylesheet", href: "main.css")
      end
    end

    def main_content
      @main
    end

    def sidebar_content
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

