# frozen_string_literal: true

module Relaton
  module Gb
    # Hit.
    class Hit < Relaton::Core::Hit
      # @return [String]
      attr_reader :pid, :docref

      # @return [Date, NilClass]
      attr_reader :release_date

      # @return [String, NilClass]
      attr_reader :status

      # @return [RelatonGb::GbScraper, RelatonGb::SecScraper, RelatonGb::TScraper]
      attr_reader :scraper

      # @param pid [String]
      # @param docref [String]
      # @parma scraper [RelatonGb::GbScraper, RelatonGb::SecScraper, RelatonGb::TScraper]
      # @param release_date [String]
      # @status [String, NilClass]
      # @param hit_collection [RelatonGb:HitCollection, NilClass]
      def initialize(pid:, docref:, scraper:, **args)
        @pid            = pid
        @docref         = docref
        @scraper        = scraper
        @release_date   = Date.parse args[:release_date] if args[:release_date]
        @status         = args[:status]
        @hit_collection = args[:hit_collection]
      end

      # Parse page.
      # @return [Isobib::IsoBibliographicItem]
      def item
        @item ||= scraper.scrape_doc self
      end

      # @return [String]
      def inspect
        "<#{self.class}:#{format('%<id>#.14x', id: object_id << 1)} " \
          "@fullIdentifier=\"#{@fetch&.shortref}\" " \
          "@docref=\"#{docref}\">"
      end
    end
  end
end
