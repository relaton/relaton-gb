# encoding: UTF-8
# frozen_string_literal: true

require "jing"
require "relaton/gb/gb_scraper"
require "relaton/gb/t_scraper"

RSpec.describe Relaton::Gb do
  before do
    Relaton::Gb.instance_variable_set :@configuration, nil
    Relaton::Gb::GbScraper.instance_variable_set :@agent, nil
    Relaton::Gb::TScraper.instance_variable_set :@agent, nil
  end

  it "has a version number" do
    expect(Relaton::Gb::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = Relaton::Gb.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  xit "scrapes social standard" do
    VCR.use_cassette "t-zs-0467—2023" do
      item = Relaton::Gb::Bibliography.get "T/ZS 0467—2023"
      expect(item).to be_instance_of Relaton::Gb::ItemData
    end
  end

  it "fetch national standard" do
    VCR.use_cassette "gb_t_20223_2006" do
      hits = Relaton::Gb::Bibliography.search "GB/T 20223-2006"
      expect(hits).to be_instance_of Relaton::Gb::HitCollection
      expect(hits.first).to be_instance_of Relaton::Gb::Hit
      expect(hits.first.item).to be_instance_of Relaton::Gb::ItemData
      file_path = "spec/fixtures/gbt_20223_2006.xml"
      xml = hits.first.item.to_xml bibdata: true
      File.write file_path, xml unless File.exist? file_path
      expect(xml).to be_equivalent_to File.open(file_path, "r:UTF-8", &:read)
        .sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
      schema = Jing.new "grammars/relaton-gb-compile.rng"
      errors = schema.validate file_path
      expect(errors).to eq []
    end
  end

  it "fetch sector standard" do
    VCR.use_cassette "jb_t_13368_2018" do
      hits = Relaton::Gb::Bibliography.search "JB/T 13368-2018"
      expect(hits).to be_instance_of Relaton::Gb::HitCollection
      expect(hits.first).to be_instance_of Relaton::Gb::Hit
      expect(hits.first.item).to be_instance_of Relaton::Gb::ItemData
      file_path = "spec/fixtures/jbt_13368_2018.xml"
      xml = hits.first.item.to_xml bibdata: true
      File.write file_path, xml unless File.exist? file_path
      expect(xml).to be_equivalent_to File.open(file_path, "r:UTF-8", &:read)
        .sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
      schema = Jing.new "grammars/relaton-gb-compile.rng"
      errors = schema.validate file_path
      expect(errors).to eq []
    end
  end

  xit "fetch social standard" do
    VCR.use_cassette "t_gzaepi_001_20018" do
      hits = Relaton::Gb::Bibliography.search "T/GZAEPI 001-2018"
      expect(hits).to be_instance_of Relaton::Gb::HitCollection
      expect(hits.first).to be_instance_of Relaton::Gb::Hit
      expect(hits.first.item).to be_instance_of Relaton::Gb::ItemData
      file_path = "spec/fixtures/tgzaepi_001_2018.xml"
      xml = hits.first.item.to_xml bibdata: true
      File.write file_path, xml unless File.exist? file_path
      expect(xml).to be_equivalent_to File.open(file_path, "r:UTF-8", &:read)
        .sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
      schema = Jing.new "grammars/relaton-gb-compile.rng"
      errors = schema.validate file_path
      expect(errors).to eq []
    end
  end

  describe "relaton_gb get", vcr: "gb_t_5606_1_2004" do
    it "gets a code" do
      expect do
        file = "spec/fixtures/gbt_5606_1_2004.xml"
        results = Relaton::Gb::Bibliography.get("GB/T 5606.1", 2004, {}).to_xml
        File.write file, results, encoding: "UTF-8" unless File.exist? file
        expect(results).to be_equivalent_to File.read(file, encoding: "UTF-8")
          .sub(/(?<=<fetched>)[^<]+/, Date.today.to_s)
      end.to output(include(
        "[relaton-gb] INFO: (GB/T 5606.1-2004) Fetching from openstd.samr.gov.cn ...",
        "[relaton-gb] INFO: (GB/T 5606.1-2004) Found: `GB/T\s5606\.1-2004`"
      )).to_stderr_from_any_process
    end

    it "gets an all-parts code", vcr: "gb_t_5606_2004_all_parts" do
      file = "spec/fixtures/gbt_5606_2004_all_parts.xml"
      results = Relaton::Gb::Bibliography.get("GB/T 5606", 2004, all_parts: true).to_xml
      File.write file, results, encoding: "UTF-8" unless File.exist? file
      expect(results).to be_equivalent_to File.read(file, encoding: "UTF-8")
        .gsub(/(?<=<fetched>)[^<]+/, Date.today.to_s)
    end

    it "gets a code and year successfully" do
      VCR.use_cassette "gb_t_20223_2006" do
        results = Relaton::Gb::Bibliography.get("GB/T 20223", "2006", {}).to_xml
        expect(results).to include %(<on>2006-03-10</on>)
        expect(results).not_to include %(<docidentifier type="Chinese Standard" primary="true">GB/T 20223.1-2006</docidentifier>)
        expect(results).to include %(<docidentifier type="Chinese Standard" primary="true">GB/T 20223-2006</docidentifier>)
      end
    end

    it "gets a code and year unsuccessfully", vcr: "gb_t_20223_2014" do
      expect do
        results = Relaton::Gb::Bibliography.get("GB/T 20223", "2014", {})
        expect(results).to be nil
      end.to output(/\[relaton-gb\] INFO: \(GB\/T 20223-2014\) Not found\./).to_stderr_from_any_process
    end

    it "gets a referece with a year in a code" do
      VCR.use_cassette "gb_t_20223_2006" do
        result = Relaton::Gb::Bibliography.get("GB/T 20223-2006").to_xml
        expect(result).to include %(<on>2006-03-10</on>)
      end
    end

    it "getd a reference without a year in a code" do
      VCR.use_cassette "gb_t_1_1" do
        result = Relaton::Gb::Bibliography.get("GB/T 1.1", nil, {})
        expect(result.relation[0].bibitem.date[0].at.to_date.year).to eq 2020
      end
    end

    it "create GbBibliographicItem from XML" do
      xml = File.open "spec/fixtures/gbt_20223_2006.xml", "r:UTF-8", &:read
      item = Relaton::Gb::Item.from_xml xml
      expect(item).to be_instance_of Relaton::Gb::ItemData
      expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
    end

    xit "warn if XML doesn't have bibitem or bibdata element" do
      expect do
        item = Relaton::Gb::Item.from_xml ""
        expect(item).to be_nil
      end.to output(/\[relaton-bib\] WARN: Can't find bibitem/).to_stderr_from_any_process
    end
  end
end
