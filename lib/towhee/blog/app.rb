require 'towhee/prerender/engine'
require 'towhee/blog/view_enumerator'
require 'towhee/blog/site'

module Towhee::Blog
  class App
    def initialize(fs)
      @fs = fs
    end

    def prerender
      site = Site.new
      engine.changed(site)
    end

    private

    def engine
      Towhee::Prerender::Engine.new(
        fs: @fs,
        view_enumerator: ViewEnumerator.new,
      )
    end
  end
end
