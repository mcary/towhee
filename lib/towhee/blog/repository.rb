require 'towhee'

module Towhee::Blog
  class Repository
    def initialize(site_hash:)
      @hash = site_hash.dup
      @sites = site_hash.keys
      @posts = site_hash.values.flat_map {|posts| posts}
    end

    def all_sites
      @sites.dup
    end

    def site_posts(site)
      @posts.dup
    end

    def post_site(post)
      site, posts = @hash.find {|k, v| v.include? post }
      site
    end

    def recent_posts(site)
      @posts.reverse.take(3)
    end
  end
end
