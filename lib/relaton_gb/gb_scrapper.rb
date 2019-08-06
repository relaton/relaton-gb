# encoding: UTF-8
# frozen_string_literal: true

require "open-uri"
require "nokogiri"
require "relaton_gb/scrapper"
require "relaton_gb/gb_bibliographic_item"

module RelatonGb
  # National standard scrapper.
  module GbScrapper
    extend Scrapper

    class << self
      # @param text [Strin] code of standard for serarch
      # @return [RelatonGb::HitCollection]
      def scrape_page(text)
        search_html = OpenURI.open_uri(
          "http://www.std.gov.cn/search/stdPage?q=" + text
        )
        result = Nokogiri::HTML search_html
        hits = result.css(".s-title a").map do |h|
          Hit.new pid: h[:pid], title: h.text, scrapper: self
        end
        HitCollection.new hits
      rescue OpenURI::HTTPError, SocketError, OpenSSL::SSL::SSLError
        raise RelatonBib::RequestError, "Cannot access http://www.std.gov.cn/search/stdPage"
      end

      # @param pid [Strin] standard's page id
      # @return [RelatonGb::GbBibliographicItem]
      def scrape_doc(pid)
        src = "http://www.std.gov.cn/gb/search/gbDetailed?id=" + pid
        doc = Nokogiri::HTML OpenURI.open_uri(src)
        GbBibliographicItem.new scrapped_data(doc, src: src)
      rescue OpenURI::HTTPError, SocketError, OpenSSL::SSL::SSLError
        raise RelatonBib::RequestError, "Cannot access #{src}"
      end

      # @param doc [Nokogiri::HTML]
      # @return [Hash]
      #   * :type [String]
      #   * :name [String]
      def get_committee(doc)
        name = doc.xpath("//p/a[1]/following-sibling::text()").text.
          match(/(?<=（)[^）]+/).to_s
        { type: "technical", name: name }
      end
    end
  end
end
