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
    SEARCH_URL = "https://openstd.samr.gov.cn/bzgk/gb/std_list"
    DOC_URL = "http://openstd.samr.gov.cn/bzgk/gb/newGbInfo?hcno="

    class << self
      # @param text [Strin] code of standard for serarch
      # @return [RelatonGb::HitCollection]
      def scrape_page(text) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        doc = agent.get("#{SEARCH_URL}?p.p2=#{CGI.escape(text)}")
        hits = doc.xpath(
          "//table[contains(@class, 'result_list')]/tbody[2]/tr",
        ).map do |h|
          ref = h.at "./td[2]/a"
          pid = ref[:onclick].match(/[0-9A-F]+/).to_s
          rdate = h.at("./td[7]").text
          Hit.new pid: pid, docref: ref.text, scrapper: self, release_date: rdate
        end
        HitCollection.new hits.sort_by(&:release_date).reverse
      rescue Mechanize::Error => e
        raise RelatonBib::RequestError, e.message
      end

      def agent
        @agent ||= Mechanize.new
      end

      # @param hit [RelatonGb::Hit] standard's page id
      # @return [RelatonGb::GbBibliographicItem]
      def scrape_doc(hit)
        src = DOC_URL + hit.pid
        doc = agent.get src
        GbBibliographicItem.new(**scrapped_data(doc, src, hit))
      rescue Mechanize::Error => e
        raise RelatonBib::RequestError, e.message
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
