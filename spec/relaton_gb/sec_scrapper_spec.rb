require "relaton_gb/sec_scrapper"

RSpec.describe RelatonGb::SecScrapper  do
  context "raise error when" do

    it "scrape page" do
      expect(Net::HTTP).to receive(:post).and_raise Timeout::Error
      expect { RelatonGb::SecScrapper.scrape_page("code") }.
        to raise_error RelatonBib::RequestError
    end

    it "scrape doc" do
      expect(Net::HTTP).to receive(:get).and_raise Timeout::Error
      hit = RelatonGb::Hit.new pid: "pid", docref: "ref", scrapper: nil
      expect { RelatonGb::SecScrapper.scrape_doc(hit) }.
        to raise_error RelatonBib::RequestError
    end
  end
end

