require 'towhee/blog/home_view'
require 'towhee/blog/post_view'

module Towhee::Blog
  class ViewEnumerator
    def initialize(repo:)
      @repo = repo
    end

    def views_for_model(model)
      # Use case to invert dependency so this class depends on models,
      # not the other way around.
      case model
      when Site
        [HomeView.new(site: model, posts: @repo.site_posts(model))]
      when Post
        [PostView.new(
          post: model,
          site: site=@repo.post_site(model),
          recent: @repo.recent_posts(site),
        )]
      else
        raise "Unknown model: #{model}"
      end
    end
  end
end
