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
      def scrape_page(text) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        host = "https://openstd.samr.gov.cn/bzgk/gb/std_list"
        search_html = OpenURI.open_uri("#{host}?p.p2=#{text}", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
        result = Nokogiri::HTML search_html
        hits = result.xpath(
          "//table[contains(@class, 'result_list')]/tbody[2]/tr",
        ).map do |h|
          ref = h.at "./td[2]/a"
          pid = ref[:onclick].match(/[0-9A-F]+/).to_s
          rdate = h.at("./td[7]").text
          Hit.new pid: pid, docref: ref.text, scrapper: self, release_date: rdate
        end
        HitCollection.new hits.sort_by(&:release_date).reverse
      rescue OpenURI::HTTPError, SocketError, OpenSSL::SSL::SSLError, Net::OpenTimeout
        raise RelatonBib::RequestError, "Cannot access #{host}"
      end

      # @param hit [RelatonGb::Hit] standard's page id
      # @return [RelatonGb::GbBibliographicItem]
      def scrape_doc(hit)
        src = "http://openstd.samr.gov.cn/bzgk/gb/newGbInfo?hcno=#{hit.pid}"
        doc = Nokogiri::HTML OpenURI.open_uri(src, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
        GbBibliographicItem.new(**scrapped_data(doc, src, hit))
      rescue OpenURI::HTTPError, SocketError, OpenSSL::SSL::SSLError, Net::OpenTimeout
        raise RelatonBib::RequestError, "Cannot access #{src}"
      end

      # @param doc [Nokogiri::HTML]
      # @param _ref [String]
      # @return [Hash]
      #   * :type [String]
      #   * :name [String]
      def get_committee(doc, _ref)
        name = doc.at("//div[contains(., '归口单位') or contains(., '归口部门')]/following-sibling::div")
        { type: "technical", name: name.text.delete("\r\n\t\t") }
      end
    end
  end
end
