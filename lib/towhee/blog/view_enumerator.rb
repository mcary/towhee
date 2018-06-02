require 'towhee/blog/home_view'

module Towhee::Blog
  class ViewEnumerator
    def initialize(repo:)
      @repo = repo
    end

    def views_for_model(model)
      [HomeView.new(model, posts: @repo.site_posts(model))]
    end
  end
end
