require 'towhee'

module Towhee::Blog
  class HomeView
    def initialize(site, posts: [])
      @site = site
      @posts = posts
    end

    def path
      "index.html"
    end

    def render
      <<-END
        <html>
          <h1>#{@site.name} Home<h1>

          #{if @posts.any?
              post_list
            else
              empty_message
            end }
        </html>
      END
    end

    private

    def post_list
      <<-END
        <ul>
          #{post_list_items}
        </ul>
      END
    end

    def post_list_items
      @posts.map do |post|
        "<li>#{post.title}</li>"
      end.join
    end

    def empty_message
      "<p>No posts yet.</p>"
    end
  end
end
