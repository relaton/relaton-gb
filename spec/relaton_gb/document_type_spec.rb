describe RelatonGb::DocumentType do
  it "warns if invalid doctype" do
    expect do
      RelatonGb::DocumentType.new type: "invalid"
    end.to output(/\[relaton-gb\] WARNING: invalid doctype: `invalid`/).to_stderr
  end
end
