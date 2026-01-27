# frozen_string_literal: true

require_relative "hit"

module Relaton
  module Gb
    # Page of hit collection
    class HitCollection < Relaton::Core::HitCollection
      # @param hits [Array<Hash>]
      # @param hit_pages [Integer]
      # @param scraper [RelatonGb::GbScraper, RelatonGb::SecScraper,
      #   RelatonGb::TScraper]
      def initialize(hits = [])
        @array = hits
        @fetched = false
      end
    end
  end
end
