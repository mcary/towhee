require 'towhee/prerender/engine'
require 'towhee/blog/view_enumerator'
require 'towhee/blog/site'

module Towhee::Blog
  class App
    def prerender(fs)
      engine = Towhee::Prerender::Engine.new(
        fs: fs,
        view_enumerator: ViewEnumerator.new,
      )
      site = Site.new
      engine.changed(site)
    end
  end
end
