# encoding: UTF-8
# frozen_string_literal: true

require "open-uri"
require "net/http"
require "nokogiri"
require "relaton_gb/scrapper"
require "relaton_gb/gb_bibliographic_item"
require "relaton_gb/hit_collection"
require "relaton_gb/hit"

module RelatonGb
  # Social standard scarpper.
  module TScrapper
    extend Scrapper

    class << self
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # @param text [String]
      # @return [RelatonGb::HitCollection]
      def scrape_page(text)
        search_html = OpenURI.open_uri(
          "http://www.ttbz.org.cn/Home/Standard?searchType=2&key=" \
          "#{CGI.escape(text.tr('-', [8212].pack('U')))}",
        ).read
        header = Nokogiri::HTML search_html
        xpath = '//table[contains(@class, "standard_list_table")]/tr/td/a'
        t_xpath = "../preceding-sibling::td[4]"
        hits = header.xpath(xpath).map do |h|
          docref = h.at(t_xpath).text.gsub(/â\u0080\u0094/, "-")
          status = h.at("../preceding-sibling::td[1]").text.delete "\r\n"
          pid = h[:href].sub(%r{/$}, "")
          Hit.new pid: pid, docref: docref, status: status, scrapper: self
        end
        HitCollection.new hits
      rescue OpenURI::HTTPError, SocketError, OpenSSL::SSL::SSLError, Net::OpenTimeout
        raise RelatonBib::RequestError, "Cannot access http://www.ttbz.org.cn/Home/Standard"
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      # @param hit [RelatonGb::Hit] standard's page path
      # @return [RelatonGb::GbBibliographicItem]
      def scrape_doc(hit)
        src = "http://www.ttbz.org.cn#{hit.pid}"
        doc = Nokogiri::HTML OpenURI.open_uri(src), nil, Encoding::UTF_8.to_s
        GbBibliographicItem.new(**scrapped_data(doc, src, hit))
      rescue OpenURI::HTTPError, SocketError, OpenSSL::SSL::SSLError, Net::OpenTimeout
        raise RelatonBib::RequestError, "Cannot access #{src}"
      end

      private

      # rubocop:disable Metrics/MethodLength
      # @param doc [Nokogiri::HTML::Document]
      # @param src [String]
      # @param hit [RelatonGb::Hit]
      # @return [Hash]
      def scrapped_data(doc, src, hit)
        # docid_xpt  = '//td[contains(.,"标准编号")]/following-sibling::td[1]'
        # status_xpt = '//td[contains(.,"标准状态")]/following-sibling::td[1]/span'
        {
          committee: get_committee(doc, hit.docref),
          docid: get_docid(hit.docref),
          title: get_titles(doc),
          doctype: get_type,
          docstatus: get_status(doc, hit.status),
          gbtype: gbtype,
          ccs: get_ccs(doc),
          ics: get_ics(doc),
          link: [{ type: "src", content: src }],
          date: get_dates(doc),
          language: ["zh"],
          script: ["Hans"],
          structuredidentifier: fetch_structuredidentifier(hit.docref),
        }
      end
      # rubocop:enable Metrics/MethodLength

      def get_committee(doc, _ref)
        {
          name: doc.xpath('//td[.="团体名称"]/following-sibling::td[1]').text,
          type: "technical",
        }
      end

      def get_titles(doc)
        xpz = '//td[contains(.,"中文标题")]/following-sibling::td[1]'
        titles = RelatonBib::TypedTitleString.from_string doc.at(xpz)
          .text, "zh", "Hans"
        xpe = '//td[contains(.,"英文标题")]/following-sibling::td[1]'
        ten = doc.xpath(xpe).text
        return titles if ten.empty?

        titles + RelatonBib::TypedTitleString.from_string(ten, "en", "Latn")
      end

      def gbtype
        { scope: "social-group", prefix: "T", mandate: "mandatory",
          topic: "other" }
      end

      def get_ccs(doc)
        [doc.xpath('//td[contains(.,"中国标准分类号")]/following-sibling::td[1]')
          .text.gsub(/[\r\n]/, "").strip.match(/^[^\s]+/).to_s]
      end

      def get_ics(doc)
        xpath = '//td[contains(.,"国际标准分类号")]/following-sibling::td[1]/span'
        ics = doc.xpath(xpath).text.match(/^[^\s]+/).to_s
        field, group, subgroup = ics.split "."
        [{ field: field, group: group.ljust(3, "0"), subgroup: subgroup }]
      end

      def get_dates(doc)
        d = doc.xpath('//td[contains(.,"发布日期")]/following-sibling::td[1]/span')
          .text.match(/(?<y>\d{4})[^\d]+(?<m>\d{2})[^\d]+(?<d>\d{2})/)
        [{ type: "published", on: "#{d[:y]}-#{d[:m]}-#{d[:d]}" }]
      end
    end
  end
end
