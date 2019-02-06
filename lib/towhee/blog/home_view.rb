require 'towhee'
require 'towhee/html/writer'

module Towhee::Blog
  class HomeView
    def initialize(site:, posts: [])
      @site = site
      @posts = posts
      @html = Towhee::HTML::Writer.new
    end

    def path
      "index.html"
    end

    def render
      @html.html do
        head + body
      end.to_s
    end

    def key
      @site.name
    end

    private

    def head
      @html.head do
        @html.title { @site.name } +
          @html.script(src: "main.js") +
          @html.link(rel: "stylesheet", href: "main.css")
      end
    end

    def body
      @html.body do
        @html.div class: "container" do
          row(style: "border-bottom: 1px solid black") do
            col(12) { header_content }
          end +
            row do
              col(8) { main_content } +
                col(4) { "" }
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

    def main_content
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
