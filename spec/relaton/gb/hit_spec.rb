RSpec.describe Relaton::Gb::Hit do
  subject { Relaton::Gb::Hit.new pid: "1234", docref: "ref", scraper: nil }

  it "returns string" do
    expect(subject.to_s).to eq(
      "<Relaton::Gb::Hit:#{format('%<id>#.14x', id: subject.object_id << 1)} "\
      "@fullIdentifier=\"\" @docref=\"ref\">",
    )
  end
end
