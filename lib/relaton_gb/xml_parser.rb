require "nokogiri"

module RelatonGb
  class XMLParser < RelatonIsoBib::XMLParser
    class << self
      private

      # override RelatonBib::BibliographicItem.bib_item method
      # @param item_hash [Hash]
      # @return [RelatonGb::GbBibliographicItem]
      def bib_item(item_hash)
        GbBibliographicItem.new(**item_hash)
      end

      def item_data(gbitem)
        data = super
        data[:committee] = fetch_committee gbitem
        data[:gbtype] = fetch_gbtype gbitem
        data[:ccs] = fetch_ccs gbitem
        data[:plannumber] = gbitem.at("./plannumber")&.text
        data
      end

      def fetch_committee(doc)
        committee = doc.at "./ext/gbcommittee"
        return nil unless committee

        { type: committee[:type], name: committee.text }
      end

      def fetch_ccs(doc)
        doc.xpath("./ext/ccs/code").map &:text
      end

      def fetch_gbtype(doc)
        gbtype = doc.at "./ext/gbtype"
        {
          scope: gbtype&.at("gbscope")&.text,
          prefix: gbtype&.at("gbprefix")&.text,
          mandate: gbtype&.at("gbmandate")&.text,
          topic: gbtype&.at("gbtopic")&.text,
        }
      end

      def create_doctype(type)
        DocumentType.new type: type.text, abbreviation: type[:abbreviation]
      end
    end
  end
end
