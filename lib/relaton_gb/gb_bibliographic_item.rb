# frozen_string_literal: true

require "relaton_iso_bib"
require "cnccs"
require "relaton_gb/gb_technical_committee"
require "relaton_gb/gb_standard_type"
require "relaton_gb/xml_parser"
require "relaton_gb/hash_converter"
require "relaton_gb/ccs"

module RelatonGb
  # GB bibliographic item class.
  class GbBibliographicItem < RelatonIsoBib::IsoBibliographicItem
    # @return [RelatonGb::GbTechnicalCommittee]
    attr_reader :committee

    # @return [RelatonGb::GbStandardType]
    attr_reader :gbtype

    # @return [String]
    attr_reader :topic

    # @return [Array<Cnccs::Ccs>]
    attr_reader :ccs

    # @return [String]
    attr_reader :plan_number

    # @return [String]
    attr_reader :type, :gbplannumber

    def initialize(**args)
      super
      @committee = GbTechnicalCommittee.new **args[:committee] if args[:committee]
      @ccs = args[:ccs].map { |c| c.is_a?(Cnccs::Ccs) ? c : Cnccs.fetch(c) }
      @gbtype = GbStandardType.new **args[:gbtype]
      @gbplannumber = args[:gbplannumber] ||
        structuredidentifier&.project_number
    end

    # @param hash [Hash]
    # @return [RelatonGb::GbBibliographicItem]
    def self.from_hash(hash)
      item_hash = ::RelatonGb::HashConverter.hash_to_bib(hash)
      new **item_hash
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata
    # @option opts [Symbol, NilClass] :date_format (:short), :full
    # @option opts [String, Symbol] :lang language
    # @return [String] XML
    def to_xml(**opts)
      super(**opts) do |b|
        if opts[:bibdata] && has_ext_attrs?
          b.ext do
            b.doctype doctype if doctype
            b.horizontal horizontal unless horizontal.nil?
            # b.docsubtype docsubtype if docsubtype
            committee&.to_xml b
            ics.each { |i| i.to_xml b }
            structuredidentifier&.to_xml b
            b.stagename stagename if stagename
            render_gbxml(b)
          end
        end
      end
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize
      hash = super
      hash["ccs"] = single_element_array(ccs) if ccs&.any?
      hash["committee"] = committee.to_hash if committee
      hash["plannumber"] = gbplannumber if gbplannumber
      hash["gbtype"] = gbtype.to_hash
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      out = super
      ccs.each { |c| out += c.to_aciibib prefix, ccs.size }
      out
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{format('%<id>#.14x', id: object_id << 1)}>"
    end

    # @return [String]
    def to_s
      inspect
    end

    def makeid(id, attribute, _delim = "")
      return nil if attribute && !@id_attribute

      id ||= @docidentifier.reject { |i| i.type == "DOI" }[0]
      idstr = id.id
      idstr.gsub(/\s/, "").strip
    end

    private

    # @param builder [Nokogiri::XML::Builder]
    def render_gbxml(builder)
      gbtype.to_xml builder

      ccs&.each do |c|
        builder.ccs do
          builder.code c.code
          builder.text_ c.description
        end
      end

      builder.plannumber gbplannumber if gbplannumber
    end

    #
    # @return [Boolean]
    #
    def has_ext_attrs?
      super || committee || docsubtype
    end
  end
end
