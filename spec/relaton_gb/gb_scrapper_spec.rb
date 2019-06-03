require "relaton_gb/gb_scrapper"

RSpec.describe RelatonGb::GbScrapper  do
  context "raise error when" do
    before(:each) { expect(OpenURI).to receive(:open_uri).and_raise SocketError }

    it "scrape page" do
      expect { RelatonGb::GbScrapper.scrape_page("code") }.
        to output(/Cannot access/).to_stderr
    end

    it "scrape doc" do
      expect { RelatonGb::GbScrapper.scrape_doc("pid") }.
        to output(/Cannot access/).to_stderr
    end
  end
end
