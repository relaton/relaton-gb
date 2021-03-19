# frozen_string_literal: true

require "relaton/processor"

module RelatonGb
  class Processor < Relaton::Processor
    def initialize
      @short = :relaton_gb
      @prefix = "CN"
      @defaultprefix = %r{^(GB|GB/T|GB/Z) }
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
      ::RelatonGb::GbBibliographicItem.new hash
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonGb.grammar_hash
    end
  end
end
