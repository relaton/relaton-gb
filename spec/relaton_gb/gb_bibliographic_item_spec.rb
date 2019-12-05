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

  it "returns Hash" do
    hash = YAML.load_file "spec/examples/gb_bib_item.yml"
    item_hash = RelatonGb::HashConverter.hash_to_bib hash
    item = RelatonGb::GbBibliographicItem.new item_hash
    h = item.to_hash
    expect(h["committee"]).to eq hash["committee"]
    expect(h["ics"]).to eq hash["ics"]
    expect(h["structuredidentifier"]).to eq hash["structuredidentifier"]
    expect(h["gbtype"]).to eq hash["gbtype"]
    expect(h["ccs"]).to eq hash["ccs"]
    expect(h["plannumber"]).to eq hash["plannumber"]
  end
end
