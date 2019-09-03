require "relaton_gb/t_scrapper"

RSpec.describe RelatonGb::TScrapper do
  context "raise error" do
    before(:each) { expect(OpenURI).to receive(:open_uri).and_raise SocketError }

    it "scrape page" do
      expect { RelatonGb::TScrapper.scrape_page("code") }.
        to raise_error RelatonBib::RequestError
    end

    it "scrape doc" do
      hit = RelatonGb::Hit.new pid: "pid", docref: "ref", scrapper: nil
      expect { RelatonGb::TScrapper.scrape_doc(hit) }.
        to raise_error RelatonBib::RequestError
    end
  end
end
