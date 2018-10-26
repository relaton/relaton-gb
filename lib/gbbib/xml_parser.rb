require 'nokogiri'

module Gbbib
  class XMLParser < IsoBibItem::XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        GbBibliographicItem.new(
          docid:        fetch_docid(doc),
          edition:      doc.at('/bibitem/edition')&.text,
          language:     doc.xpath('/bibitem/language').map(&:text),
          script:       doc.xpath('/bibitem/script').map(&:text),
          titles:       fetch_titles(doc),
          type:         doc.at('bibitem')&.attr(:type),
          docstatus:    fetch_status(doc),
          ics:          fetch_ics(doc),
          dates:        fetch_dates(doc),
          contributors: fetch_contributors(doc),
          workgroup:    fetch_workgroup(doc),
          abstract:     fetch_abstract(doc),
          copyright:    fetch_copyright(doc),
          link:         fetch_link(doc),
          relations:    fetch_relations(doc),
          committee:    fetch_committee(doc),
          ccs:          fetch_ccs(doc),
          gbtype:       fetch_gbtype(doc)
        )
      end

      private

      # Overrade get_id from IsoBibItem::XMLParser
      def get_id(did)
        id = did.text.match(/^(?<project>.*?\d+)(?<hyphen>-)?(?(<hyphen>)(?<year>\d*))/)
      end

      def fetch_committee(doc)
        committee = doc.at '/bibitem/gbcommittee' || return nil
        { type: committee[:type], name: committee.text }
      end

      def fetch_ccs(doc)
        doc.xpath('/bibitem/ccs/code').map &:text
      end

      def fetch_gbtype(doc)
        gbtype = doc.at '/bibitem/gbtype'
        {
          scope: gbtype&.at('gbscope')&.text,
          prefix: gbtype&.at('gbprefix')&.text,
          mandate: gbtype&.at('gbmandate')&.text
        }
      end
    end
  end
end
