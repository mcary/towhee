require 'towhee'

module Towhee::Blog
  class Repository
    def initialize(sites:)
      @sites = sites.dup
    end

    def all_sites
      @sites.dup
    end
  end
end
