# encoding: UTF-8
# frozen_string_literal: true

require "net/http"
require "json"
require "nokogiri"
require "relaton_gb/scrapper"
require "relaton_gb/gb_bibliographic_item"
require "relaton_gb/hit_collection"
require "relaton_gb/hit"

module RelatonGb
  # Sector standard scrapper
  module SecScrapper
    extend Scrapper

    class << self
      # @param text [String] code of standard for serarch
      # @return [RelatonGb::HitCollection]
      def scrape_page(text)
        uri = URI "http://www.std.gov.cn/hb/search/hbPage?searchText=#{text}"
        res = JSON.parse Net::HTTP.get(uri)
        hits = res["rows"].map do |r|
          Hit.new pid: r["id"], title: r["STD_CODE"], scrapper: self
        end
        HitCollection.new hits
      rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
        raise RelatonBib::RequestError, "Cannot access #{uri}"
      end

      # @param pid [String] standard's page id
      # @return [RelatonGb::GbBibliographicItem]
      def scrape_doc(pid)
        src = "http://www.std.gov.cn/hb/search/stdHBDetailed?id=#{pid}"
        page_uri = URI src
        doc = Nokogiri::HTML Net::HTTP.get(page_uri)
        GbBibliographicItem.new scrapped_data(doc, src: src)
      rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
        raise RelatonBib::RequestError, "Cannot access #{src}"
      end

      private

      # @param doc [Nokogiri::HTML::Document]
      # @return [Hash]
      #   * :type [String]
      #   * :name [String]
      def get_committee(doc)
        ref = get_ref(doc)
        name = get_prefix(ref)["administration"]
        { type: "technical", name: name }
      end
    end
  end
end
