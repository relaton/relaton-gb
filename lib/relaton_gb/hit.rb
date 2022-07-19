# frozen_string_literal: true

module RelatonGb
  # Hit.
  class Hit < RelatonBib::Hit
    # @return [String]
    attr_reader :pid, :docref

    # @return [Date, NilClass]
    attr_reader :release_date

    # @return [String, NilClass]
    attr_reader :status

    # @return [RelatonGb::GbScrapper, RelatonGb::SecScraper, RelatonGb::TScrapper]
    attr_reader :scrapper

    # @param pid [String]
    # @param docref [String]
    # @parma scrapper [RelatonGb::GbScrapper, RelatonGb::SecScraper, RelatonGb::TScrapper]
    # @param release_date [String]
    # @status [String, NilClass]
    # @param hit_collection [RelatonGb:HitCollection, NilClass]
    def initialize(pid:, docref:, scrapper:, **args)
      @pid            = pid
      @docref         = docref
      @scrapper       = scrapper
      @release_date   = Date.parse args[:release_date] if args[:release_date]
      @status         = args[:status]
      @hit_collection = args[:hit_collection]
    end

    # Parse page.
    # @return [Isobib::IsoBibliographicItem]
    def fetch
      @fetch ||= scrapper.scrape_doc self
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{format('%<id>#.14x', id: object_id << 1)} " \
        "@fullIdentifier=\"#{@fetch&.shortref}\" " \
        "@docref=\"#{docref}\">"
    end
  end
end
