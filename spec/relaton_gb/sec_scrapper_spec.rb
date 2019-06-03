require "relaton_gb/sec_scrapper"

RSpec.describe RelatonGb::SecScrapper  do
  context "raise error when" do
    before(:each) { expect(Net::HTTP).to receive(:get).and_raise Timeout::Error }

    it "scrape page" do
      expect { RelatonGb::SecScrapper.scrape_page("code") }.
        to output(/Cannot access/).to_stderr
    end

    it "scrape doc" do
      expect { RelatonGb::SecScrapper.scrape_doc("pid") }.
        to output(/Cannot access/).to_stderr
    end
  end
end

