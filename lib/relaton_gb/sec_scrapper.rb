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
        # uri = URI "http://www.std.gov.cn/hb/search/hbPage?searchText=#{text}"
        uri = URI "https://hbba.sacinfo.org.cn/stdQueryList"
        resp = Net::HTTP.post uri, URI.encode_www_form({ key: text })
        # res = JSON.parse Net::HTTP.get(uri)
        json = JSON.parse resp.body
        hits = json["records"].map do |h|
          Hit.new pid: h["pk"], docref: h["code"], status: h["status"], scrapper: self
        end
        # hits = res["rows"].map do |r|
        #   Hit.new pid: r["id"], title: r["STD_CODE"], scrapper: self
        # end
        HitCollection.new hits
      rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
             OpenSSL::SSL::SSLError, Errno::ETIMEDOUT, Net::OpenTimeout
        raise RelatonBib::RequestError, "Cannot access #{uri}"
      end

      # @param hit [RelatonGb::Hit]
      # @return [RelatonGb::GbBibliographicItem]
      def scrape_doc(hit)
        src = "https://hbba.sacinfo.org.cn/stdDetail/#{hit.pid}"
        page_uri = URI src
        doc = Nokogiri::HTML Net::HTTP.get(page_uri)
        GbBibliographicItem.new(**scrapped_data(doc, src, hit))
      rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
             OpenSSL::SSL::SSLError, Errno::ETIMEDOUT, Net::OpenTimeout
        raise RelatonBib::RequestError, "Cannot access #{src}"
      end

      private

      # @param doc [Nokogiri::HTML::Document]
      # @return [Array<Hash>]
      #   * :title_intro [String]
      #   * :title_main [String]
      #   * :language [String]
      #   * :script [String]
      def get_titles(doc)
        # titles = [{ title_main: doc.at("//h4").text.delete("\r\n\t"),
        #             title_intro: nil, language: "zh", script: "Hans" }]
        tzh = doc.at("//h4").text.delete("\r\n\t")
        RelatonBib::TypedTitleString.from_string tzh, "zh", "Hans"
        # title_main = doc.at("//td[contains(text(), '英文标准名称')]").text.match(/[\w\s]+/).to_s
        # unless title_main.empty?
        #   titles << { title_main: title_main, title_intro: nil, language: "en", script: "Latn" }
        # end
        # titles
      end

      # @param _doc [Nokogiri::HTML::Document]
      # @param ref [String]
      # @return [Hash]
      #   * :type [String]
      #   * :name [String]
      def get_committee(_doc, ref)
        # ref = get_ref(doc)
        name = get_prefix(ref)["administration"]
        { type: "technical", name: name }
      end

      # @param _doc [Nokogiri::HTML::Document]
      # @return [String]
      def get_scope(_doc)
        "sector"
      end

      # @param doc [Nokogiri::HTML::Document]
      # @return [Array<String>]
      def get_ccs(doc)
        [doc.at("//dt[contains(text(), '中国标准分类号')]/following-sibling::dd").text]
      end
    end
  end
end
