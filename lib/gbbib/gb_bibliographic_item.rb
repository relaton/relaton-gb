# frozen_string_literal: true

require 'iso_bib_item'
require 'cnccs'
require 'gbbib/gb_technical_committee'
require 'gbbib/gb_standard_type'

module Gbbib
  # GB bibliographic item class.
  class GbBibliographicItem < IsoBibItem::IsoBibliographicItem
    # @return [Gbbib::GbTechnicalCommittee]
    attr_reader :committee

    # @return [Gbbib::GbStandardType]
    attr_reader :gbtype

    # @return [String]
    attr_reader :topic

    # @return [Array<Cnccs::Ccs>]
    attr_reader :ccs

    # @return [String]
    attr_reader :plan_number

    # @return [String]
    attr_reader :type

    def initialize(**args)
      super
      @committee = GbTechnicalCommittee.new args[:committee]
      @ccs = args[:ccs].map { |c| Cnccs.fetch c }
      @gbtype = GbStandardType.new args[:gbtype]
      @type = args[:type]
    end

    # @param builder [Nokogiri::XML::Builder]
    # @return [String]
    def to_xml(builder = nil, **opts)
      if builder
        super(builder, opts) { |xml| render_gbxml(xml) }
      else
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |bldr|
          super(bldr, opts) { |xml| render_gbxml(xml) }
        end.doc.root.to_xml
      end
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{format('%#.14x', object_id << 1)}>"
      # "@fullIdentifier=\"#{@fetch&.shortref}\" "\
      # "@title=\"#{title}\">"
    end

    # @return [String]
    def to_s
      inspect
    end

    private

    # @param builder [Nokogiri::XML::Builder]
    def render_gbxml(builder)
      committee.to_xml builder
      gbtype.to_xml builder
      ccs.each { |c| builder.ccs c.description } if ccs.any?
    end
  end
end
