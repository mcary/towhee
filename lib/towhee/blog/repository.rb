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

    def category_posts(category, site:)
      @category_hash[category] & site_posts(site)
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
      #
      # Can't call category_posts() because we don't have the site yet.
      category_posts = @category_hash[category]
      sites = category_posts.map { |post| post_site(post) }
      sites.first
    end

    def category_summary(site)
      pairs = site_categories(site).map do |cat|
        count = category_posts(cat, site: site).size
        [cat, count]
      end
      Hash[pairs]
    end
  end
end
