require "yaml"

RSpec.describe RelatonGb::GbBibliographicItem do
  it "returns string" do
    item = RelatonGb::GbBibliographicItem.new(
      id: "12", ccs: [], gbtype: {
        scope: "scope", prefix: "prefix", mandate: "mandate", topic: "other"
      },
      gbplannumber: "1234",
    )
    expect(item.to_s).to eq "<#{item.class}:#{format('%#.14x', item.object_id << 1)}>"
  end

  # it "raise error invalid language" do
  #   expect do
  #     RelatonGb::GbBibliographicItem.new(
  #       id: "12", ccs: [], gbtype: { scope: "scope", prefix: "prefix", mandate: "mandate" },
  #       gbplannumber: "1234", language: ["fr"]
  #     )
  #   end.to raise_error ArgumentError
  # end

  context "instance" do
    subject do
      hash = YAML.load_file "spec/examples/gb_bib_item.yml"
      item_hash = RelatonGb::HashConverter.hash_to_bib hash
      RelatonGb::GbBibliographicItem.new(**item_hash)
    end

    it "returns Hash" do
      hash = YAML.load_file "spec/examples/gb_bib_item.yml"
      h = subject.to_hash
      expect(h["ext"]["committee"]).to eq hash["ext"]["committee"]
      expect(h["ext"]["ics"][0]).to eq hash["ext"]["ics"]
      expect(h["ext"]["structuredidentifier"]).to eq hash["ext"]["structuredidentifier"]
      expect(h["ext"]["gbtype"]).to eq hash["ext"]["gbtype"]
      expect(h["ext"]["ccs"][0]).to eq hash["ext"]["ccs"]
      expect(h["ext"]["plannumber"]).to eq hash["ext"]["plannumber"]
    end

    it "returns AciiBib" do
      file = "spec/examples/asciibib.adoc"
      bib = subject.to_asciibib
        .gsub(/(?<=fetched::\s)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      File.write file, bib, encoding: "UTF-8" unless File.exist? file
      expect(bib).to eq File.read(file, encoding: "UTF-8")
        .gsub(/(?<=fetched::\s)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
    end
  end
end
