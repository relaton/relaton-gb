# frozen_string_literal: true

module RelatonGb
  # Hit.
  class Hit
    # @return [Isobib::HitCollection]
    attr_reader :hit_collection

    # @return [String]
    attr_reader :pid

    # @return [String]
    attr_reader :docref, :status

    # @return [RelatonGb::GbScrapper, RelatonGb::SecScraper, RelatonGb::TScrapper]
    attr_reader :scrapper

    # @param hit [Hash]
    # @param hit_collection [Isobib:HitCollection]
    def initialize(pid:, docref:, status: nil, hit_collection: nil, scrapper:)
      @pid            = pid
      @docref         = docref
      @status         = status
      @hit_collection = hit_collection
      @scrapper       = scrapper
      self.hit_collection << self if hit_collection
    end

    # Parse page.
    # @return [Isobib::IsoBibliographicItem]
    def fetch
      @fetch ||= scrapper.scrape_doc self
    end

    # @return [String]
    def to_s
      inspect
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{format('%#.14x', object_id << 1)} "\
      "@fullIdentifier=\"#{@fetch&.shortref}\" "\
      "@docref=\"#{docref}\">"
    end

    # @param builder [Nokogiri::XML::Builder]
    # @param opts [Hash]
    # @return [String]
    # def to_xml(builder = nil, opts = {})
    #   if builder
    #     fetch.to_xml builder, opts
    #   else
    #     builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
    #       fetch.to_xml xml, opts
    #     end
    #     builder.doc.root.to_xml
    #   end
    # end
  end
end
