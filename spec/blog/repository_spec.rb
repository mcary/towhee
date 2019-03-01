require 'towhee/blog/repository'
require 'towhee/blog/site'

RSpec.describe Towhee::Blog::Repository do
  context "no sites" do
    it "returns none" do
      repo = repository(site_hash: {})
      expect(repo.all_sites).to eq []
    end
  end

  context "one site" do
    it "returns one" do
      repo = repository(site_hash: {
        Towhee::Blog::Site.new(name: "TestSite") => [],
      })
      expect(repo.all_sites.size).to eq 1
      expect(repo.all_sites.first.name).to eq "TestSite"
    end
  end

  context "one post" do
    it "returns site's post" do
      # Posts aren't linked to sites just yet; maybe someday.
      repo = repository(site_hash: {
        :a_site => [:a_post],
        :other_site => [:other_post],
      })
      expect(repo.site_posts(:a_site)).to eq [:a_post]
    end

    it "returns post's site" do
      repo = repository(site_hash: { :a_site => [:a_post] })
      expect(repo.post_site(:a_post)).to eq :a_site
    end

    it "returns post's correct site" do
      repo = repository(site_hash: { :other_site => [], :a_site => [:a_post] })
      expect(repo.post_site(:a_post)).to eq :a_site
    end

    it "returns recent posts" do
      repo = repository(site_hash: { :a_site => (1..5).to_a })
      expect(repo.recent_posts(:a_site)).to eq [5, 4, 3]
    end
  end

  context "one category" do
    it "returns a category's posts" do
      repo = repository(category_hash: { :a_cat => [:a_post] })
      expect(repo.category_posts(:a_cat)).to eq [:a_post]
    end

    it "returns a post's correct category" do
      repo = repository(category_hash: { :other => [], :a_cat => [:a_post] })
      expect(repo.post_category(:a_post)).to eq :a_cat
    end

    it "returns a site's categories" do
      repo = repository(
        site_hash: { :a_site => [:a_post] },
        category_hash: { :a_cat => [:a_post], :other_cat => [:other_post] },
      )
      expect(repo.site_categories(:a_site)).to eq [:a_cat]
    end

    it "returns a site's distinct categories" do
      repo = repository(
        site_hash: { :a_site => [:a_post, :other_post] },
        category_hash: { :a_cat => [:a_post, :other_post] },
      )
      expect(repo.site_categories(:a_site)).to eq [:a_cat]
    end

    it "returns a category's site" do
      repo = repository(
        site_hash: { :a_site => [:a_post], :other_site => [:other_post] },
        category_hash: { :a_cat => [:a_post], :other_cat => [:other_post] },
      )
      expect(repo.category_site(:a_cat)).to eq :a_site
    end
  end

  def repository(**args)
    described_class.new(site_hash: {}, category_hash: {}, **args)
  end
end
