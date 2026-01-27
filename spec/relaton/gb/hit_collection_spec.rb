RSpec.describe Relaton::Gb::HitCollection do
  subject { Relaton::Gb::HitCollection.new }

  it "returns string" do
    expect(subject.to_s).to eq(
      "<Relaton::Gb::HitCollection:#{format('%<id>#.14x', id: subject.object_id << 1)} "\
      "@ref= @fetched=false>",
    )
  end
end
