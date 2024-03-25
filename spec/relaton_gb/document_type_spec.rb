describe RelatonGb::DocumentType do
  it "warns if invalid doctype" do
    expect do
      RelatonGb::DocumentType.new type: "invalid"
    end.to output(/\[relaton-gb\] WARN: invalid doctype: `invalid`/).to_stderr_from_any_process
  end
end
