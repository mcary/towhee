require 'towhee/prerender/engine'
require 'towhee/blog/view_enumerator'

module Towhee::Blog
  class App
    def prerender(fs)
      engine = Towhee::Prerender::Engine.new(
        fs: fs,
        view_enumerator: ViewEnumerator.new,
      )
      engine.changed(nil)
    end
  end
end
