RSpec.describe RelatonGb::GbBibliographicItem do
  it "returns string" do
    item = RelatonGb::GbBibliographicItem.new(
      id: "12", ccs: [], gbtype: { scope: "scope", prefix: "prefix", mandate: "mandate" },
      gbplannumber: "1234",
    )
    expect(item.to_s).to eq "<#{item.class}:#{format('%#.14x', item.object_id << 1)}>"
  end

  it "raise error invalid language" do
    expect do
      RelatonGb::GbBibliographicItem.new(
        id: "12", ccs: [], gbtype: { scope: "scope", prefix: "prefix", mandate: "mandate" },
        gbplannumber: "1234", language: ["fr"]
      )
    end.to raise_error ArgumentError
  end
end
