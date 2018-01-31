require 'towhee/prerender'

module Towhee::Prerender
  class Engine
    def initialize(fs:, view_enumerator:)
      @file_system = fs
      @view_enumerator = view_enumerator
    end

    def changed(model)
      views = views_for_model(model)
      views.each do |view|
        render(view)
      end
    end

    private

    def views_for_model(model)
      @view_enumerator.views_for_model(model)
    end

    def render(view)
      file_name = view.path
      content = view.render
      @file_system[file_name] = content
    end
  end
end
