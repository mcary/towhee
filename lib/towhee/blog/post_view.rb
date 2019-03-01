require 'towhee'
require 'towhee/html/writer'

module Towhee::Blog
  class PostView
    def initialize(site:, post:, recent:, category_summary:, layout:)
      @site = site
      @post = post
      @recent = recent
      @category_summary = category_summary
      @layout = layout
      @html = Towhee::HTML::Writer.new
    end

    def path
      "posts/#{@post.slug}.html"
    end

    def render
      @layout.new(
        title: @post.title + " - " + @site.name,
        main: post,
        sidebar_modules: sidebar_modules,
        site: @site,
      ).render
    end

    def key
      [@site.name, @post.slug]
    end

    private

    def post
      @html.h1 { @post.title } +
        @html.trust("\n" + @post.body)
    end

    def sidebar_modules
      [
        @html.h1 { "Recent Posts" } +
          recent_post_content,
        @html.h1 { "Categories" } +
          categories_content,
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

    def categories_content
      if @category_summary.any?
        categories_list
      else
        @html.p { "No categories yet." }
      end
    end

    def categories_list
      @html.ul do
        @html.join_fragments(
          @category_summary.map do |entry|
            category_item(entry)
          end
        )
      end
    end

    def category_item(entry)
      category, post_count = entry
      @html.li do
        link = @html.a href: category_path(category) do
          category.name
        end
        link + @html.text(" (#{post_count})")
      end
    end

    def category_path(category)
      "/categories/#{category.slug}.html"
    end
  end
end
