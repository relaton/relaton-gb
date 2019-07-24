# encoding: UTF-8
# frozen_string_literal: true

require "yaml"
require "gb_agencies"

module RelatonGb
  # Common scrapping methods.
  module Scrapper
    @prefixes = nil

    # rubocop:disable Metrics/MethodLength
    # @param doc [Nokogiri::HTML::Document]
    # @param src [String] url of scrapped page
    # @return [Hash]
    def scrapped_data(doc, src:)
      {
        committee: get_committee(doc),
        docid: get_docid(doc),
        title: get_titles(doc),
        contributor: get_contributors(doc),
        type: get_type(doc),
        docstatus: get_status(doc),
        gbtype: get_gbtype(doc),
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

    # @param doc [Nokogiri::HTML::Document]
    # @param xpt [String]
    # @return [Array<RelatonBib::DocumentIdentifier>]
    def get_docid(doc, xpt = '//dt[text()="标准号"]/following-sibling::dd[1]')
      item_ref = doc.at xpt
      return [] unless item_ref

      [RelatonBib::DocumentIdentifier.new(id: item_ref.text, type: "Chinese Standard")]
    end

    # @param doc [Nokogiri::HTML::Document]
    # @param xpt [String]
    # @return [RelatonIsoBib::StructuredIdentifier]
    def fetch_structuredidentifier(doc, xpt = '//dt[text()="标准号"]/following-sibling::dd[1]')
      item_ref = doc.at xpt
      unless item_ref
        return RelatonIsoBib::StructuredIdentifier.new(
          project_number: "?", part_number: "?", prefix: nil, id: "?",
          type: "Chinese Standard"
        )
      end

      m = item_ref.text.match(/^([^–—.-]*\d+)\.?((?<=\.)\d+|)/)
      # prefix = doc.xpath(xpt).text.match(/^[^\s]+/).to_s
      RelatonIsoBib::StructuredIdentifier.new(
        project_number: m[1], part_number: m[2], prefix: nil,
        id: item_ref.text, type: "Chinese Standard"
      )
    end

    def get_contributors(doc, xpt = '//dt[text()="标准号"]/following-sibling::dd[1]')
      gb_en = GbAgencies::Agencies.new("en", {}, "")
      gb_zh = GbAgencies::Agencies.new("zh", {}, "")
      name = doc.xpath(xpt).text.match(/^[^\s]+/).to_s
      name.sub!(%r{/[TZ]$}, "") unless name =~ /^GB/
      gbtype = get_gbtype(doc)
      entity = RelatonBib::Organization.new name: [
        { language: "en", content: gb_en.standard_agency1(gbtype[:scope], name, gbtype[:mandate]) },
        { language: "zh", content: gb_zh.standard_agency1(gbtype[:scope], name, gbtype[:mandate]) },
      ]
      [{ entity: entity, role: ["publisher"] }]
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [Array<Hash>]
    #   * :title_intro [String]
    #   * :title_main [String]
    #   * :language [String]
    #   * :script [String]
    def get_titles(doc)
      titles = [{ title_main: doc.css("div.page-header h4").text, title_intro: nil,
                  language: "zh", script: "Hans" }]
      title_main = doc.css("div.page-header h5").text
      unless title_main.empty?
        titles << { title_main: title_main, title_intro: nil, language: "en", script: "Latn" }
      end
      titles
    end

    def get_type(_doc)
      "international-standard"
    end

    # @param doc [Nokogiri::HTML::Document]
    # @param xpt [String]
    # @return [RelatonBib::DocumentStatus]
    def get_status(doc, xpt = ".s-status.label:nth-child(3)")
      case doc.at(xpt).text.gsub(/\s/, "")
      when "即将实施"
        stage = "published"
      when "现行"
        stage = "activated"
      when "废止"
        stage = "obsoleted"
      end
      RelatonBib::DocumentStatus.new stage: stage
    end

    private

    # @param doc [Nokogiri::HTML::Document]
    # @return [Hash]
    #   * :scope [String]
    #   * :prefix [String]
    #   * :mandate [String]
    def get_gbtype(doc)
      ref = get_ref(doc)
      { scope: get_scope(doc), prefix: get_prefix(ref)["prefix"],
        mandate: get_mandate(ref) }
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [String]
    def get_ref(doc)
      doc.xpath('//dt[text()="标准号"]/following-sibling::dd[1]').text
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [Array<String>]
    def get_ccs(doc)
      [doc&.xpath('//dt[text()="中国标准分类号"]/following-sibling::dd[1]')&.text]
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [Array<Hash>]
    #   * :field [String]
    #   * :group [String]
    #   * :subgroup [String]
    def get_ics(doc)
      ics = doc.xpath('//dt[(.="国际标准分类号")]/following-sibling::dd[1]/span')
      return [] if ics.empty?

      field, group, subgroup = ics.text.split "."
      [{ field: field, group: group.ljust(3, "0"), subgroup: subgroup }]
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [String]
    def get_scope(doc)
      scope = doc.at(".s-status.label-info").text
      if scope == "国家标准"
        "national"
      elsif scope =~ /^行业标准/
        "sector"
      end
    end

    # @param ref [String]
    # @return [String]
    def get_prefix(ref)
      pref = ref.match(/^[^\s]+/).to_s.split("/").first
      prefix pref
    end

    # @param pref [String]
    # @return [Hash{String=>String}]
    def prefix(pref)
      file_path = File.join(__dir__, "yaml/prefixes.yaml")
      @prefixes ||= YAML.load_file(file_path)
      @prefixes[pref]
    end

    # @param ref [String]
    # @return [String]
    def get_mandate(ref)
      case ref.match(%r{(?<=\/)[^\s]+}).to_s
      when "T" then "recommended"
      when "Z" then "guidelines"
      else "mandatory"
      end
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [Array<Hash>]
    #   * :type [String] type of date
    #   * :on [String] date
    def get_dates(doc)
      date = doc.xpath('//dt[.="发布日期"]/following-sibling::dd[1]').text
      [{ type: "published", on: date }]
    end
  end
end
