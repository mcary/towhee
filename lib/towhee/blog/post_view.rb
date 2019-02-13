require 'towhee'
require 'towhee/html/writer'

module Towhee::Blog
  class PostView
    def initialize(site:, post:, recent: [])
      @site = site
      @post = post
      @recent = recent
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
          @html.h1 { "Recent Posts" } +
            recent_post_content
        end
      end
    end

    def recent_post_content
      if @recent.any?
        recent_post_list
      else
        @html.p { "No other recent posts." }
      end
    end

    def recent_post_list
      @html.ul do
        @html.join_fragments(
          @recent.map do |post|
            post_item(post)
          end
        )
      end
    end

    def post_item(post)
      @html.li do
        @html.a href: post_path(post) do
          post.title
        end
      end
    end

    def post_path(post)
      "/posts/#{post.slug}.html"
    end
  end
end
