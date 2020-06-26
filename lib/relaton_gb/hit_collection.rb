# frozen_string_literal: true

module RelatonGb
  # Page of hit collection
  class HitCollection < RelatonBib::HitCollection
    # @param hits [Array<Hash>]
    # @param hit_pages [Integer]
    # @param scrapper [RelatonGb::GbScrapper, RelatonGb::SecScrapper,
    #   RelatonGb::TScrapper]
    def initialize(hits = [])
      @array = hits
      @fetched = false
    end
  end
end
