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
            @html.h1 { @post.title } +
              @html.trust("\n" + @post.body)
          end
      end.to_s
    end

    private
  end
end
