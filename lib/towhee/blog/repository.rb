require 'towhee'

module Towhee::Blog
  class Repository
    def initialize(site_hash:, category_hash:)
      @site_hash = site_hash.dup
      @sites = site_hash.keys
      @posts = site_hash.values.flat_map {|posts| posts}
      @category_hash = category_hash.dup
    end

    def all_sites
      @sites.dup
    end

    def site_posts(site)
      @site_hash[site].dup
    end

    def post_site(post)
      site, posts = @site_hash.find {|k, v| v.include? post }
      site
    end

    def recent_posts(site)
      @posts.reverse.take(3)
    end

    def category_posts(category)
      @category_hash[category].dup
    end

    def post_category(post)
      cat, posts = @category_hash.find { |cat, posts| posts.include?(post) }
      cat
    end

    def site_categories(site)
      site_posts(site).map { |post| post_category(post) }.uniq.compact
    end

    def category_site(category)
      # For now we assume that a category exists within a single site,
      # because content in the same category should be presented together
      # for SEO.
      sites = category_posts(category).map { |post| post_site(post) }
      sites.first
    end
  end
end
