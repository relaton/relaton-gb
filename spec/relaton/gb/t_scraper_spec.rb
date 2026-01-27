require "relaton/gb/t_scraper"

RSpec.describe Relaton::Gb::TScraper do
  before(:each) do
    described_class.instance_variable_set :@agent, nil
  end

  context "when 404 response" do
    it "scrape_page returns nil" do
      agent = double("agent")
      expect(Mechanize).to receive(:new).and_return agent
      error = Mechanize::ResponseCodeError.new(double(code: "404"))
      expect(agent).to receive(:get).and_raise error
      expect(described_class.scrape_page("code")).to be_nil
    end
  end

  context "when non-404 response error" do
    it "scrape_page raises RequestError" do
      agent = double("agent")
      expect(Mechanize).to receive(:new).and_return agent
      error = Mechanize::ResponseCodeError.new(double(code: "500"))
      expect(agent).to receive(:get).and_raise error
      expect { described_class.scrape_page("code") }.
        to raise_error Relaton::RequestError
    end
  end

  context "when Mechanize::Error" do
    before(:each) do
      agent = double("agent")
      expect(Mechanize).to receive(:new).and_return agent
      expect(agent).to receive(:get).and_raise Mechanize::Error
    end

    it "scrape_page raises RequestError" do
      expect { described_class.scrape_page("code") }.
        to raise_error Relaton::RequestError
    end

    it "scrape_doc raises RequestError" do
      hit = Relaton::Gb::Hit.new pid: "pid", docref: "ref", scraper: nil
      expect { described_class.scrape_doc(hit) }.
        to raise_error Relaton::RequestError
    end
  end
end
