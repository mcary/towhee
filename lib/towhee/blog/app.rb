require 'towhee/prerender/engine'
require 'towhee/blog/view_enumerator'

module Towhee::Blog
  class App
    def initialize(fs:, repo:)
      @fs = fs
      @repo = repo
    end

    def prerender
      engine.batch_changed(@repo.all_sites)
    end

    private

    def engine
      Towhee::Prerender::Engine.new(
        fs: @fs,
        view_enumerator: ViewEnumerator.new(repo: @repo),
      )
    end
  end
end
