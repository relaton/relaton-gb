require "relaton_gb/t_scrapper"

RSpec.describe RelatonGb::TScrapper do
  context "raise error" do
    before(:each) { expect(OpenURI).to receive(:open_uri).and_raise SocketError }

    it "scrape page" do
      expect { RelatonGb::TScrapper.scrape_page("code") }.
        to output(/Cannot access/).to_stderr
    end

    it "scrape doc" do
      expect { RelatonGb::TScrapper.scrape_doc("pid") }.
        to output(/Cannot access/).to_stderr
    end
  end
end
