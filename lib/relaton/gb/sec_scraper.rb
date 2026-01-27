# encoding: UTF-8
# frozen_string_literal: true

require "net/http"
require "json"
require "nokogiri"
require_relative "scraper"
require_relative "item"
require_relative "hit_collection"
require_relative "hit"

module Relaton
  module Gb
    # Sector standard scraper
    module SecScraper
      extend Scraper
      extend Core::ArrayWrapper

      class << self
        # @param text [String] code of standard for serarch
        # @return [Relaton::Gb::HitCollection]
        def scrape_page(text)
          # uri = URI "http://www.std.gov.cn/hb/search/hbPage?searchText=#{text}"
          uri = URI "https://hbba.sacinfo.org.cn/stdQueryList"
          resp = Net::HTTP.post uri, URI.encode_www_form({ key: text })
          # res = JSON.parse Net::HTTP.get(uri)
          json = JSON.parse resp.body
          hits = json["records"].map do |h|
            Hit.new pid: h["pk"], docref: h["code"], status: h["status"], scraper: self
          end
          # hits = res["rows"].map do |r|
          #   Hit.new pid: r["id"], title: r["STD_CODE"], scraper: self
          # end
          HitCollection.new hits
        rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
              Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
              OpenSSL::SSL::SSLError, Errno::ETIMEDOUT, Net::OpenTimeout
          raise Relaton::RequestError, "Cannot access #{uri}"
        end

        # @param hit [Relaton::Gb::Hit]
        # @return [Relaton::Gb::ItemData]
        def scrape_doc(hit)
          src = "https://hbba.sacinfo.org.cn/stdDetail/#{hit.pid}"
          page_uri = URI src
          doc = Nokogiri::HTML Net::HTTP.get(page_uri)
          ItemData.new(**scrapped_data(doc, src, hit))
        rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
              Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
              OpenSSL::SSL::SSLError, Errno::ETIMEDOUT, Net::OpenTimeout
          raise Relaton::RequestError, "Cannot access #{src}"
        end

        private

        # @param doc [Nokogiri::HTML::Document]
        # @return [Array<Relaton::Bib::Title>]
        def get_titles(doc)
          # titles = [{ title_main: doc.at("//h4").text.delete("\r\n\t"),
          #             title_intro: nil, language: "zh", script: "Hans" }]
          tzh = doc.at("//h4").text.delete("\r\n\t")
          [Bib::Title.from_string(tzh, "zh", "Hans")]
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
        # def get_committee(_doc, ref)
        #   # ref = get_ref(doc)
        #   name = get_prefix(ref)["administration"]
        #   { type: "technical", name: name }
        # end

        # @param _doc [Nokogiri::HTML::Document]
        # @return [String]
        def get_scope(_doc)
          "sector"
        end

        # @param doc [Nokogiri::HTML::Document]
        # @return [Array<String>]
        def get_ccs(doc)
          array(doc.at("//dt[contains(text(), '中国标准分类号')]/following-sibling::dd")).map do |cc|
            text = Cnccs.fetch(cc.text.strip)&.description
            CCS.new code: cc.text, text: text
          end
        end
      end
    end
  end
end
