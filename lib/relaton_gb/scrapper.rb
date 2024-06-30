# encoding: UTF-8
# frozen_string_literal: true

require "yaml"
require "gb_agencies"

module RelatonGb
  # Common scrapping methods.
  module Scrapper
    STAGES = { "即将实施" => "published",
               "现行" => "activated",
               "废止" => "obsoleted",
               "被代替" => "replaced" }.freeze

    @prefixes = nil

    # @param doc [Nokogiri::HTML::Document]
    # @param src [String]
    # @param hit [RelatonGb::Hit]
    # @return [Hash]
    def scrapped_data(doc, src, hit) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      {
        fetched: Date.today.to_s,
        committee: get_committee(doc, hit.docref),
        docid: get_docid(hit.docref),
        title: get_titles(doc),
        contributor: get_contributors(doc, hit.docref),
        doctype: get_type,
        docstatus: get_status(doc, hit.status),
        gbtype: get_gbtype(doc, hit.docref),
        ccs: get_ccs(doc),
        ics: get_ics(doc),
        link: [{ type: "src", content: src }],
        date: get_dates(doc),
        language: ["zh"],
        script: ["Hans"],
        structuredidentifier: fetch_structuredidentifier(hit.docref),
      }
    end

    # @param docref [String]
    # @return [Array<RelatonBib::DocumentIdentifier>]
    def get_docid(docref)
      [RelatonBib::DocumentIdentifier.new(id: docref, type: "Chinese Standard", primary: true)]
    end

    # @param docref [String]
    # @return [RelatonIsoBib::StructuredIdentifier]
    def fetch_structuredidentifier(docref)
      m = docref.match(/^([^–—.-]*\d+)\.?((?<=\.)\d+|)/)
      RelatonIsoBib::StructuredIdentifier.new(
        project_number: m[1], part_number: m[2], prefix: nil,
        id: docref, type: "Chinese Standard"
      )
    end

    # @param doc [Nokogiri::HTML::Document]
    # @param docref [Strings]
    # @return [Array<Hash>]
    def get_contributors(doc, docref)
      name = docref.match(/^[^\s]+/).to_s
      name.sub!(%r{/[TZ]$}, "") unless name =~ /^GB/
      gbtype = get_gbtype(doc, docref)
      orgs = %w[en zh].map { |l| org(l, name, gbtype) }.compact
      return [] unless orgs.any?

      entity = RelatonBib::Organization.new name: orgs
      [{ entity: entity, role: [type: "publisher"] }]
    end

    # @param lang [String]
    # @param name [String]
    # @param gbtype [Hash]
    # @return [Hash]
    def org(lang, name, gbtype)
      ag = GbAgencies::Agencies.new(lang, {}, "")
      content = ag.standard_agency1(gbtype[:scope], name, gbtype[:mandate])
      return unless content

      { language: lang, content: content }
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [Array<RelatonBib::TypedTitleString>]
    def get_titles(doc)
      tzh = doc.at("//td[contains(text(), '中文标准名称')]/b").text
      titles = RelatonBib::TypedTitleString.from_string tzh, "zh", "Hans"
      ten = doc.at("//td[contains(text(), '英文标准名称')]").text.match(/[\w\s]+/).to_s
      return titles if ten.empty?

      titles + RelatonBib::TypedTitleString.from_string(ten, "en", "Latn")
    end

    def get_type
      DocumentType.new type: "standard"
    end

    # @param doc [Nokogiri::HTML::Document]
    # @param status [String, NilClass]
    # @return [RelatonBib::DocumentStatus]
    def get_status(doc, status = nil)
      status ||= doc.at("//td[contains(., '标准状态')]/span")&.text&.strip
      return unless STAGES[status]

      RelatonBib::DocumentStatus.new stage: STAGES[status]
    end

    private

    # @param doc [Nokogiri::HTML::Document]
    # @param ref [String]
    # @return [Hash]
    #   * :scope [String]
    #   * :prefix [String]
    #   * :mandate [String]
    def get_gbtype(doc, ref)
      # ref = get_ref(doc)
      { scope: get_scope(doc), prefix: get_prefix(ref)["prefix"],
        mandate: get_mandate(ref), topic: "other" }
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [Array<String>]
    def get_ccs(doc)
      [doc.at("//div[contains(text(), '中国标准分类号')]/following-sibling::div").
        text.delete("\r\n\t\t")]
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [Array<Hash>]
    #   * :field [String]
    #   * :group [String]
    #   * :subgroup [String]
    def get_ics(doc)
      ics = doc.at("//div[contains(text(), '国际标准分类号')]/following-sibling::div"\
                   " | //dt[contains(text(), '国际标准分类号')]/following-sibling::dd")
      return [] unless ics

      field, group, subgroup = ics.text.delete("\r\n\t\t").split "."
      [{ field: field, group: group.ljust(3, "0"), subgroup: subgroup }]
    end

    # @param doc [Nokogiri::HTML::Document]
    # @return [String]
    def get_scope(doc)
      issued = doc.at("//div[contains(., '发布单位')]/following-sibling::div")
      case issued&.text
      when /国家标准/ then "national"
      when /^行业标准/ then "sector"
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
      @prefixes ||= YAML.load_file File.join(__dir__, "yaml/prefixes.yaml")
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
      date = doc.at("//div[contains(text(), '发布日期')]/following-sibling::div"\
                    " | //dt[contains(text(), '发布日期')]/following-sibling::dd")
      [{ type: "published", on: date.text.delete("\r\n\t\t") }]
    end
  end
end
