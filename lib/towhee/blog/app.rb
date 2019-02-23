require 'towhee/prerender/engine'
require 'towhee/blog/view_enumerator'

module Towhee::Blog
  class App
    def initialize(fs:, repo:)
      @fs = fs
      @repo = repo
    end

    def prerender
      first_site = @repo.all_sites.first
      engine.batch_changed(@repo.all_sites +
                           @repo.site_posts(first_site) +
                           @repo.site_categories(first_site))
    end

    private

    def engine
      Towhee::Prerender::Engine.new(
        fs: @fs,
        view_enumerator: view_enumerator,
      )
    end

    def view_enumerator
      ViewEnumerator.new(repo: @repo)
    end
  end
end
