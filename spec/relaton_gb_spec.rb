# encoding: UTF-8
# frozen_string_literal: true

require "open-uri"
require "net/http"
require "jing"

RSpec.describe RelatonGb do
  it "has a version number" do
    expect(RelatonGb::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonGb.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  it "fetch national standard" do
    VCR.use_cassette "gb_t_20223_2006" do
      hits = RelatonGb::GbBibliography.search "GB/T 20223-2006"
      expect(hits).to be_instance_of RelatonGb::HitCollection
      expect(hits.first).to be_instance_of RelatonGb::Hit
      expect(hits.first.fetch).to be_instance_of RelatonGb::GbBibliographicItem
      file_path = "spec/examples/gbt_20223_2006.xml"
      xml = hits.first.fetch.to_xml bibdata: true
      File.write file_path, xml unless File.exist? file_path
      expect(xml).to be_equivalent_to File.open(file_path, "r:UTF-8", &:read)
        .sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
      schema = Jing.new "spec/examples/isobib.rng"
      errors = schema.validate file_path
      expect(errors).to eq []
    end
  end

  it "fetch sector standard" do
    VCR.use_cassette "jb_t_13368_2018" do
      hits = RelatonGb::GbBibliography.search "JB/T 13368-2018"
      expect(hits).to be_instance_of RelatonGb::HitCollection
      expect(hits.first).to be_instance_of RelatonGb::Hit
      expect(hits.first.fetch).to be_instance_of RelatonGb::GbBibliographicItem
      file_path = "spec/examples/jbt_13368_2018.xml"
      xml = hits.first.fetch.to_xml bibdata: true
      File.write file_path, xml unless File.exist? file_path
      expect(xml).to be_equivalent_to File.open(file_path, "r:UTF-8", &:read)
        .sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
      schema = Jing.new "spec/examples/isobib.rng"
      errors = schema.validate file_path
      expect(errors).to eq []
    end
  end

  it "fetch social standard" do
    VCR.use_cassette "t_gzaepi_001_20018" do
      hits = RelatonGb::GbBibliography.search "T/GZAEPI 001-2018"
      expect(hits).to be_instance_of RelatonGb::HitCollection
      expect(hits.first).to be_instance_of RelatonGb::Hit
      expect(hits.first.fetch).to be_instance_of RelatonGb::GbBibliographicItem
      file_path = "spec/examples/tgzaepi_001_2018.xml"
      xml = hits.first.fetch.to_xml bibdata: true
      File.write file_path, xml unless File.exist? file_path
      expect(xml).to be_equivalent_to File.open(file_path, "r:UTF-8", &:read)
        .sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
      schema = Jing.new "spec/examples/isobib.rng"
      errors = schema.validate file_path
      expect(errors).to eq []
    end
  end

  describe "relaton_gb get" do
    it "gets a code" do
      VCR.use_cassette "gb_t_5606_1_2004" do
        results = RelatonGb::GbBibliography.get("GB/T 5606.1", 2004, {}).to_xml
        expect(results).to include %(<bibitem id="GB/T5606.1-2004" type="standard">)
        expect(results).to include %(<on>2004-12-14</on>)
        expect(results).to include %(<docidentifier type="Chinese Standard">GB/T 5606.1-2004</docidentifier>)
        expect(results).not_to include %(<docidentifier type="Chinese Standard">GB/T 5606</docidentifier>)
      end
    end

    it "gets an all-parts code" do
      VCR.use_cassette "gb_t_5606_2004_all_parts" do
        results = RelatonGb::GbBibliography.get("GB/T 5606", 2004, all_parts: true).to_xml
        expect(results).to include %(<bibitem id="GB/T5606.1-2004" type="standard">)
        expect(results).to include %(<docidentifier type="Chinese Standard">GB/T 5606\.1-2004</docidentifier>)
        expect(results).to include %(<docidentifier type="Chinese Standard">GB/T 5606 (all parts)</docidentifier>)
      end
    end

    it "gets a code and year successfully" do
      VCR.use_cassette "gb_t_20223_2006" do
        results = RelatonGb::GbBibliography.get("GB/T 20223", "2006", {}).to_xml
        expect(results).to include %(<on>2006-03-10</on>)
        expect(results).not_to include %(<docidentifier type="Chinese Standard">GB/T 20223.1-2006</docidentifier>)
        expect(results).to include %(<docidentifier type="Chinese Standard">GB/T 20223-2006</docidentifier>)
      end
    end

    it "gets a code and year unsuccessfully" do
      VCR.use_cassette "gb_t_20223_2014" do
        results = RelatonGb::GbBibliography.get("GB/T 20223", "2014", {})
        expect(results).to be nil
      end
    end

    it "gets a referece with a year in a code" do
      VCR.use_cassette "gb_t_20223_2006" do
        result = RelatonGb::GbBibliography.get("GB/T 20223-2006").to_xml
        expect(result).to include %(<on>2006-03-10</on>)
      end
    end

    it "getd a reference without a year in a code" do
      VCR.use_cassette "gb_t_1_1" do
        result = RelatonGb::GbBibliography.get("GB/T 1.1", nil, {})
        expect(result.relation[0].bibitem.date[0].on(:year)).to eq 2020
      end
    end

    it "create GbBibliographicItem from XML" do
      xml = File.open "spec/examples/gbt_20223_2006.xml", "r:UTF-8", &:read
      item = RelatonGb::XMLParser.from_xml xml
      expect(item).to be_instance_of RelatonGb::GbBibliographicItem
      expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
    end

    it "warn if XML doesn't have bibitem or bibdata element" do
      item = ""
      expect { item = RelatonGb::XMLParser.from_xml "" }.to output(/can't find bibitem/)
        .to_stderr
      expect(item).to be_nil
    end
  end
end
