require "relaton/gb/sec_scraper"

RSpec.describe Relaton::Gb::SecScraper  do
  context "raise error when" do
    it "scrape page" do
      expect(Net::HTTP).to receive(:post).and_raise Timeout::Error
      expect { described_class.scrape_page("code") }.
        to raise_error Relaton::RequestError
    end

    it "scrape doc" do
      expect(Net::HTTP).to receive(:get).and_raise Timeout::Error
      hit = Relaton::Gb::Hit.new pid: "pid", docref: "ref", scraper: nil
      expect { described_class.scrape_doc(hit) }.
        to raise_error Relaton::RequestError
    end
  end
end
