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
      args[:committee] && @committee = GbTechnicalCommittee.new(args[:committee])
      @ccs = args[:ccs].map { |c| c.is_a?(Cnccs::Ccs) ? c : Cnccs.fetch(c) }
      @gbtype = GbStandardType.new args[:gbtype]
      @gbplannumber = args[:gbplannumber] || structuredidentifier&.project_number
      # @doctype = args[:doctype]
    end

    # @param builder [Nokogiri::XML::Builder]
    # @return [String]
    def to_xml(builder = nil, **opts)
      if builder
        super(builder, **opts) { |xml| render_gbxml(xml) }
      else
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |bldr|
          super(bldr, **opts) { |xml| render_gbxml(xml) }
        end.doc.root.to_xml
      end
    end

    # @return [Hash]
    def to_hash
      hash = super
      hash["ccs"] = single_element_array(ccs) if ccs&.any?
      hash["committee"] = committee.to_hash if committee
      hash["plannumber"] = gbplannumber if gbplannumber
      hash["gbtype"] = gbtype.to_hash
      hash
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
  end
end
