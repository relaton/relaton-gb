require "relaton/gb/gb_scraper"

RSpec.describe Relaton::Gb::GbScraper  do
  context "raise error when" do
    before(:each) do
      agent = double("agent")
      expect(Mechanize).to receive(:new).and_return agent
      expect(agent).to receive(:get).and_raise Mechanize::Error
      described_class.instance_variable_set :@agent, nil
    end

    it "scrape page" do
      expect { described_class.scrape_page("code") }.
        to raise_error Relaton::RequestError
    end

    it "scrape doc" do
      hit = Relaton::Gb::Hit.new pid: "pid", docref: "ref", scraper: nil
      expect { described_class.scrape_doc(hit) }.
        to raise_error Relaton::RequestError
    end
  end
end
