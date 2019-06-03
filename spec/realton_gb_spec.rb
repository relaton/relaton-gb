# encoding: UTF-8
# frozen_string_literal: true

require "open-uri"
require "net/http"

RSpec.describe RelatonGb do
  it "has a version number" do
    expect(RelatonGb::VERSION).not_to be nil
  end

  it "fetch national standard" do
    open_uri_stub count: 2
    hits = RelatonGb::GbBibliography.search "GB/T 20223-2006"
    expect(hits).to be_instance_of RelatonGb::HitCollection
    expect(hits.first).to be_instance_of RelatonGb::Hit
    expect(hits.first.fetch).to be_instance_of RelatonGb::GbBibliographicItem
    file_path = "spec/examples/gbt_20223_2006.xml"
    xml = hits.first.fetch.to_xml bibdata: true
    File.write file_path, xml unless File.exist? file_path
    expect(xml).to be_equivalent_to File.open(file_path, "r:UTF-8", &:read).
      sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
  end

  it "fetch sector standard" do
    net_http_stub "json"
    net_http_stub
    hits = RelatonGb::GbBibliography.search "JB/T 13368-2018"
    expect(hits).to be_instance_of RelatonGb::HitCollection
    expect(hits.first).to be_instance_of RelatonGb::Hit
    expect(hits.first.fetch).to be_instance_of RelatonGb::GbBibliographicItem
    file_path = "spec/examples/jbt_13368_2018.xml"
    xml = hits.first.fetch.to_xml bibdata: true
    File.write file_path, xml unless File.exist? file_path
    expect(xml).to be_equivalent_to File.open(file_path, "r:UTF-8", &:read).
      sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
  end

  it "fetch social standard" do
    open_uri_stub count: 2
    hits = RelatonGb::GbBibliography.search "T/GZAEPI 001-2018"
    expect(hits).to be_instance_of RelatonGb::HitCollection
    expect(hits.first).to be_instance_of RelatonGb::Hit
    expect(hits.first.fetch).to be_instance_of RelatonGb::GbBibliographicItem
    file_path = "spec/examples/tgzaepi_001_2018.xml"
    xml = hits.first.fetch.to_xml bibdata: true
    File.write file_path, xml unless File.exist? file_path
    expect(xml).to be_equivalent_to File.open(file_path, "r:UTF-8", &:read).
      sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
  end

  describe "relaton_gb get" do
    # let(:hits) { RelatonGb::GbBibliography.search('19115') }

    it "gets a code" do
      open_uri_stub count: 2
      results = RelatonGb::GbBibliography.get("GB/T 5606.1", 2004, {}).to_xml
      expect(results).to include %(<bibitem id="GB/T5606.1-2004" type="international-standard">)
      expect(results).to include %(<on>2004</on>)
      expect(results).to include %(<docidentifier type="Chinese Standard">GB/T 5606.1-2004</docidentifier>)
      expect(results).not_to include %(<docidentifier type="Chinese Standard">GB/T 5606</docidentifier>)
    end

    it "gets an all-parts code" do
      open_uri_stub count: 2
      results = RelatonGb::GbBibliography.get("GB/T 5606", 2004, all_parts: true).to_xml
      expect(results).to include %(<bibitem id="GB/T5606.1-2004" type="international-standard">)
      expect(results).to include %(<docidentifier type="Chinese Standard">GB/T 5606\.1-2004</docidentifier>)
      expect(results).to include %(<docidentifier type="Chinese Standard">GB/T 5606-2004 (all parts)</docidentifier>)
    end

    it "gets a code and year successfully" do
      open_uri_stub count: 2
      results = RelatonGb::GbBibliography.get("GB/T 20223", "2006", {}).to_xml
      expect(results).to include %(<on>2006</on>)
      expect(results).not_to include %(<docidentifier type="Chinese Standard">GB/T 20223.1-2006</docidentifier>)
      expect(results).to include %(<docidentifier type="Chinese Standard">GB/T 20223-2006</docidentifier>)
    end

    it "gets a code and year unsuccessfully" do
      open_uri_stub count: 1
      results = RelatonGb::GbBibliography.get("GB/T 20223", "2014", {})
      expect(results).to be nil
    end

    it "gets a referece with a year in a code" do
      open_uri_stub count: 2
      result = RelatonGb::GbBibliography.get("GB/T 20223-2006").to_xml
      expect(result).to include %(<on>2006</on>)
    end

    it "create GbBibliographicItem from XML" do
      xml = File.open "spec/examples/gbt_20223_2006.xml", "r:UTF-8", &:read
      item = RelatonGb::XMLParser.from_xml xml
      expect(item).to be_instance_of RelatonGb::GbBibliographicItem
      expect(item.to_xml(bibdata: true)).to be_equivalent_to xml.sub(%r{<fetched>[^<]+</fetched>}, "<fetched>#{Date.today}</fetched>")
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def open_uri_stub(ext = "html", count: 1)
    expect(OpenURI).to receive(:open_uri).and_wrap_original do |m, *args|
      ref = args[0].match(/(?<==)[^=]+$|(?<=\/)\d+$/).to_s
      expect(args[0]).to be_instance_of String
      fetch_data(ref, ext) { m.call(*args).read }
    end.exactly(count).times
  end

  def net_http_stub(ext = "html")
    expect(Net::HTTP).to receive(:get).and_wrap_original do |m, *args|
      ref = args[0].to_s.match(/(?<==)[^=]+$|(?<=\/)\d+$/).to_s
      expect(args[0]).to be_instance_of URI::HTTP
      fetch_data(ref, ext) { m.call *args }.read
    end
  end
  # rubocop:enable Metrics/AbcSize

  def file_path(ref, ext)
    file_name = ref.downcase.delete("/").gsub(/[\s-]/, "_")
    "spec/examples/#{file_name}.#{ext}"
  end

  def fetch_data(ref, ext)
    decoded_ref = URI.decode_www_form_component(ref).tr([8212].pack("U"), "-")
    file = file_path decoded_ref, ext
    File.write file, yield, encoding: "utf-8" unless File.exist? file
    File.open file, "r:UTF-8"
  end
end
