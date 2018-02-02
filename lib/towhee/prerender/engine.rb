require 'towhee/prerender'

module Towhee::Prerender
  class Engine
    def initialize(fs:, view_enumerator:)
      @file_system = fs
      @view_enumerator = view_enumerator
    end

    def changed(model)
      batch_changed([model])
    end

    def batch_changed(models)
      views = models.flat_map { |model| views_for_model(model) }
      views = views.uniq(&:key)
      views.each do |view|
        render(view)
      end
    end

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
