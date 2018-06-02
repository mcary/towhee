require 'towhee'

module Towhee::Blog
  class Repository
    def initialize(sites:, posts:)
      @sites = sites.dup
      @posts = posts.dup
    end

    def all_sites
      @sites.dup
    end

    def site_posts(site)
      @posts.dup
    end
  end
end
