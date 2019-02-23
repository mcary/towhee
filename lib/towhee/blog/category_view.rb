require 'towhee'
require 'towhee/html/writer'

module Towhee::Blog
  class CategoryView
    def initialize(site:, category:, posts:, recent:, layout:)
      @site = site
      @category = category
      @posts = posts
      @recent = recent
      @layout = layout
      @html = Towhee::HTML::Writer.new
    end

    def path
      "categories/#{@category.slug}.html"
    end

    def render
      @layout.new(
        title: @category.name + " - " + @site.name,
        main: category_intro + post_listing,
        sidebar_modules: sidebar_modules,
        site: @site,
      ).render
    end

    def key
      [@site.name, @category.slug]
    end

    private

    def category_intro
      @html.h1 { @category.name } +
        @html.trust("\n" + @category.description)
    end

    def post_listing
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

    def empty_message
      @html.p { "No posts yet." }
    end

    def sidebar_modules
      [
        @html.h1 { "Recent Posts" } +
          recent_post_content,
      ]
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
