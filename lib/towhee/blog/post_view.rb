require 'towhee'
require 'towhee/html/writer'

module Towhee::Blog
  class PostView
    def initialize(site:, post:)
      @site = site
      @post = post
      @html = Towhee::HTML::Writer.new
    end

    def path
      "posts/#{@post.slug}.html"
    end

    def render
      @html.html do
        @html.head do
          @html.title { @post.title + " - " + @site.name }
        end +
          @html.body do
            post + sidebar
          end
      end.to_s
    end

    def key
      [@site.name, @post.slug]
    end

    private

    def post
      @html.h1 { @post.title } +
        @html.trust("\n" + @post.body)
    end

    def sidebar
      @html.aside do
        @html.section do
          @html.h1 { "Recent Posts" }
        end
      end
    end
  end
end
