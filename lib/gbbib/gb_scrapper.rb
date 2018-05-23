# encoding: UTF-8

require 'open-uri'
require 'nokogiri'
require 'gbbib/scrapper'
require 'gbbib/gb_bibliographic_item'

module Gbbib
  # National standard scrapper.
  module GbScrapper
    extend Scrapper

    class << self
      def scrape_page(text)
        search_html = OpenURI.open_uri(
          'http://www.std.gov.cn/search/stdPage?q=' + text
        )
        header = Nokogiri::HTML search_html
        pid = header.at('.s-title a')[:pid]
        src = 'http://www.std.gov.cn/gb/search/gbDetailed?id=' + pid
        doc = Nokogiri::HTML OpenURI.open_uri(src)
        GbBibliographicItem.new scrapped_data(doc, src: src)
      end

      def get_committee(doc)
        doc.xpath('//p/a[1]/following-sibling::text()').text
           .match(/(?<=（)[^）]+/).to_s
      end
    end
  end
end
