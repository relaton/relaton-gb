# encoding: UTF-8

require 'net/http'
require 'json'
require 'nokogiri'
require 'gbbib/scrapper'
require 'gbbib/gb_bibliographic_item'

module Gbbib
  # Sector standard scrapper
  module SecScrape
    extend Scrapper

    class << self
      def scrape_page(text)
        uri = URI "http://www.std.gov.cn/hb/search/hbPage?searchText=#{text}"
        res = JSON.parse Net::HTTP.get(uri)
        id = res['rows'][0]['id']
        src = "http://www.std.gov.cn/hb/search/stdHBDetailed?id=#{id}"
        page_uri = URI src
        doc = Nokogiri::HTML Net::HTTP.get(page_uri)
        GbBibliographicItem.new scrapped_data(doc, src: src)
      end

      private

      def get_committee(doc)
        ref = get_ref(doc)
        get_prefix(ref)['administration']
      end
    end
  end
end
