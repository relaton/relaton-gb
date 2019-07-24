# encoding: UTF-8
# frozen_string_literal: true

require "open-uri"
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
          "http://www.ttbz.org.cn/Home/Standard?searchType=2&key=" +
          CGI.escape(text.tr("-", [8212].pack("U"))),
        )
        header = Nokogiri::HTML search_html
        xpath = '//table[contains(@class, "standard_list_table")]/tr/td/a'
        t_xpath = "../preceding-sibling::td[3]"
        hits = header.xpath(xpath).map do |h|
          title = h.at(t_xpath).text.gsub(/â\u0080\u0094/, "-")
          Hit.new pid: h[:href].sub(%r{\/$}, ""), title: title, scrapper: self
        end
        HitCollection.new hits
      rescue OpenURI::HTTPError, SocketError
        raise RelatonBib::RequestError, "Cannot access http://www.ttbz.org.cn/Home/Standard"
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      # @param pid [String] standard's page path
      # @return [RelatonGb::GbBibliographicItem]
      def scrape_doc(pid)
        src = "http://www.ttbz.org.cn#{pid}"
        doc = Nokogiri::HTML OpenURI.open_uri(src), nil, Encoding::UTF_8.to_s
        GbBibliographicItem.new scrapped_data(doc, src: src)
      rescue OpenURI::HTTPError, SocketError
        raise RelatonBib::RequestError, "Cannot access #{src}"
      end

      private

      # rubocop:disable Metrics/MethodLength
      # @param doc [Nokogiri::HTML::Document]
      # @return [Hash]
      def scrapped_data(doc, src:)
        docid_xpt  = '//td[contains(.,"标准编号")]/following-sibling::td[1]'
        status_xpt = '//td[contains(.,"标准状态")]/following-sibling::td[1]/span'
        {
          committee: get_committee(doc),
          docid: get_docid(doc, docid_xpt),
          title: get_titles(doc),
          type: "international-standard",
          docstatus: get_status(doc, status_xpt),
          gbtype: gbtype,
          ccs: get_ccs(doc),
          ics: get_ics(doc),
          link: [{ type: "src", content: src }],
          date: get_dates(doc),
          language: ["zh"],
          script: ["Hans"],
          structuredidentifier: fetch_structuredidentifier(doc),
        }
      end
      # rubocop:enable Metrics/MethodLength

      def get_committee(doc)
        {
          name: doc.xpath('//td[.="团体名称"]/following-sibling::td[1]').text,
          type: "technical",
        }
      end

      def get_titles(doc)
        xpath  = '//td[contains(.,"中文标题")]/following-sibling::td[1]'
        titles = [{ title_main: doc.xpath(xpath).text,
                    title_intro: nil, language: "zh", script: "Hans" }]
        xpath = '//td[contains(.,"英文标题")]/following-sibling::td[1]'
        title_main = doc.xpath(xpath).text
        unless title_main.empty?
          titles << { title_main: title_main, title_intro: nil, language: "en",
                      script: "Latn" }
        end
        titles
      end

      def gbtype
        { scope: "social-group", prefix: "T", mandate: "mandatory" }
      end

      # def get_group_code(ref)
      #   ref.match(%r{(?<=\/)[^\s]})
      # end

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
