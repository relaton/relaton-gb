require "nokogiri"

module RelatonGb
  class XMLParser < RelatonIsoBib::XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        gbitem = doc.at "/bibitem|/bibdata"
        if gbitem
          GbBibliographicItem.new item_data(gbitem)
        else
          warn "[relato-gb] can't find bibitem or bibdata element in the XML"
        end
      end

      private

      def item_data(gbitem)
        data = super
        data[:committee] = fetch_committee gbitem
        data[:gbtype] = fetch_gbtype gbitem
        data[:ccs] = fetch_ccs gbitem
        data[:plannumber] = gbitem.at("./plannumber")&.text
        data
      end

      # Overrade get_id from RelatonIsoBib::XMLParser
      # def get_id(did)
      #   did.text.match(/^(?<project>.*?\d+)(?<hyphen>-)?(?(<hyphen>)(?<year>\d*))/)
      # end

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
    end
  end
end
