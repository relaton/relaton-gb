# encoding: UTF-8

require 'open-uri'
require 'nokogiri'
require 'gbbib/scrapper'
require 'gbbib/gb_bibliographic_item'

module Gbbib
  # Social standard scarpper.
  module TScrapper
    extend Scrapper

    class << self
      def scrape_page(text)
        search_html = OpenURI.open_uri(
          'http://www.ttbz.org.cn/Home/Standard?searchType=2&key=' +
          CGI.escape(text.tr('-', [8212].pack('U')))
        )
        header = Nokogiri::HTML search_html
        xpath = '//table[contains(@class, "standard_list_table")]/tr/td/a'
        path = header.at(xpath)[:href].sub(%r{\/$}, '')
        src = "http://www.ttbz.org.cn#{path}"
        doc = Nokogiri::HTML OpenURI.open_uri(src), nil, Encoding::UTF_8.to_s
        GbBibliographicItem.new scrapped_data(doc, src: src)
      end

      private

      def scrapped_data(doc, src:)
        docid_xpt  = '//td[contains(.,"标准编号")]/following-sibling::td[1]'
        status_xpt = '//td[contains(.,"标准状态")]/following-sibling::td[1]/span'
        {
          committee: get_committee(doc),
          docid:     get_docid(doc, docid_xpt),
          titles:    get_titles(doc),
          type:      'social_group-standard',
          docstatus: get_status(doc, status_xpt),
          gbtype:    get_gbtype(doc),
          ccs:       get_ccs(doc),
          ics:       get_ics(doc),
          source:    [{ type: 'src', content: src }],
          dates:     get_dates(doc)
        }
      end

      def get_committee(doc)
        {
          name: doc.xpath('//td[.="团体名称"]/following-sibling::td[1]').text,
          type: 'technical'
        }
      end

      def get_titles(doc)
        xpath  = '//td[contains(.,"中文标题")]/following-sibling::td[1]'
        titles = [{ title_intro: doc.xpath(xpath).text,
                    title_main: '', language: 'zh', script: 'Hans' }]
        xpath = '//td[contains(.,"英文标题")]/following-sibling::td[1]'
        title_intro = doc.xpath(xpath).text
        unless title_intro.empty?
          titles << { title_intro: title_intro, title_main: '', language: 'en',
                      script: 'Latn' }
        end
        titles
      end

      def get_gbtype(doc)
        ref = doc.xpath('//dt[text()="标准号"]/following-sibling::dd[1]').text
        { scope: 'social_group', prefix: 'T', group_code: get_group_code(ref),
          mandate: 'mandatory' }
      end

      def get_group_code(ref)
        ref.match(%r{(?<=\/)[^\s]})
      end

      def get_ccs(doc)
        [doc.xpath('//td[contains(.,"中国标准分类号")]/following-sibling::td[1]').text]
      end

      def get_ics(doc)
        ics = doc.xpath('//td[contains(.,"国际标准分类号")]/following-sibling::td[1]/span')
                 .text.match(/^[^\s]+/).to_s
        field, group, subgroup = ics.split '.'
        [{ field: field, group: group.ljust(3, '0'), subgroup: subgroup }]
      end

      def get_dates(doc)
        d = doc.xpath('//td[contains(.,"发布日期")]/following-sibling::td[1]/span')
               .text.match(/(?<y>\d{4})[^\d]+(?<m>\d{2})[^\d]+(?<d>\d{2})/)
        [{ type: 'published', from: "#{d[:y]}-#{d[:m]}-#{d[:d]}" }]
      end
    end
  end
end
