require 'iso_bib_item'
require 'cnccs'

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
    end
  end
end
