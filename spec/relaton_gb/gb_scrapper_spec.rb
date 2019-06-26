require "relaton_gb/gb_scrapper"

RSpec.describe RelatonGb::GbScrapper  do
  context "raise error when" do
    before(:each) { expect(OpenURI).to receive(:open_uri).and_raise SocketError }

    it "scrape page" do
      expect { RelatonGb::GbScrapper.scrape_page("code") }.
        to raise_error RelatonBib::RequestError
    end

    it "scrape doc" do
      expect { RelatonGb::GbScrapper.scrape_doc("pid") }.
        to raise_error RelatonBib::RequestError
    end
  end
end
