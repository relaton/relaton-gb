RSpec.describe RelatonGb::HitCollection do
  subject { RelatonGb::HitCollection.new }

  it "returns string" do
    expect(subject.to_s).to eq(
      "<RelatonGb::HitCollection:#{format('%#.14x', subject.object_id << 1)} @fetched=false>",
    )
  end
end
