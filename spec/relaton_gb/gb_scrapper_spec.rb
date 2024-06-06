require "relaton_gb/gb_scrapper"

RSpec.describe RelatonGb::GbScrapper  do
  context "raise error when" do
    before(:each) do
      agent = double("agent")
      expect(Mechanize).to receive(:new).and_return agent
      expect(agent).to receive(:get).and_raise Mechanize::Error
      described_class.instance_variable_set :@agent, nil
    end

    it "scrape page" do
      expect { RelatonGb::GbScrapper.scrape_page("code") }.
        to raise_error RelatonBib::RequestError
    end

    it "scrape doc" do
      hit = RelatonGb::Hit.new pid: "pid", docref: "ref", scrapper: nil
      expect { RelatonGb::GbScrapper.scrape_doc(hit) }.
        to raise_error RelatonBib::RequestError
    end
  end
end
