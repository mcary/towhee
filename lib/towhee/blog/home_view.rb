require 'towhee'

module Towhee::Blog
  class HomeView
    def initialize(site)
      @site = site
    end

    def path
      "index.html"
    end

    def render
      "<html>#{@site.name} Home</html>"
    end
  end
end
