# frozen_string_literal: true

require "relaton/processor"

module RelatonGb
  class Processor < Relaton::Processor
    def initialize
      @short = :relaton_gb
      @prefix = "CN"
      @defaultprefix = %r{^GB }
      @idtype = "Chinese Standard"
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonGb::GbBibliographicItem]
    def get(code, date, opts)
      ::RelatonGb::GbBibliography.get(code, date, opts)
    end

    # @param xml [String]
    # @return [RelatonGb::GbBibliographicItem]
    def from_xml(xml)
      ::RelatonGb::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonGb::GbBibliographicItem]
    def hash_to_bib(hash)
      item_hash = ::RelatonGb::HashConverter.hash_to_bib(hash)
      ::RelatonGb::GbBibliographicItem.new item_hash
    end
  end
end
