require 'towhee'
require 'towhee/html/writer'

module Towhee::Blog
  class HomeView
    def initialize(site:, posts:, layout:)
      @site = site
      @posts = posts
      @layout = layout
      @html = Towhee::HTML::Writer.new
    end

    def path
      "index.html"
    end

    def render
      @layout.new(
        title: @site.name,
        main: main,
        sidebar_modules: [],
        site: @site,
      ).render
    end

    def key
      @site.name
    end

    private

    def main
      @html.h1 { @site.name + " Home" } +
        if @posts.any?
          post_list
        else
          empty_message
        end
    end

    def post_list
      @html.ul do
        @html.join_fragments(
          @posts.map do |post|
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

    def empty_message
      @html.p { "No posts yet." }
    end
  end
end
