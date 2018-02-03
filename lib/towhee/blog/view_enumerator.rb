require 'towhee/blog/home_view'

module Towhee::Blog
  class ViewEnumerator
    def views_for_model(model)
      [HomeView.new]
    end
  end
end
