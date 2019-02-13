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
    it "returns one" do
      # Posts aren't linked to sites just yet; maybe someday.
      repo = repository(site_hash: { nil => [:a_post] })
      expect(repo.site_posts(nil).size).to eq 1
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

  def repository(**args)
    described_class.new(**args)
  end
end
