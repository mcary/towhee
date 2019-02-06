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
  end
end
