require 'towhee'
require 'towhee/html/writer'

module Towhee::Blog
  class HomeView
    def initialize(site, posts: [])
      @site = site
      @posts = posts
      @html = Towhee::HTML::Writer.new
    end

    def path
      "index.html"
    end

    def render
      @html.html do
        @html.h1 { @site.name + " Home" } +
          if @posts.any?
            post_list
          else
            empty_message
          end
      end.to_s
    end

    private

    def post_list
      @html.ul do
        @html.join_fragments(
          @posts.map do |post|
            @html.li { post.title }
          end
        )
      end
    end

    def empty_message
      @html.p { "No posts yet." }
    end
  end
end
