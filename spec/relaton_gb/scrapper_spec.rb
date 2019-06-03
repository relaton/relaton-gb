RSpec.describe RelatonGb::Scrapper do
  it "returns status published" do
    doc = Nokogiri::HTML <<~END_HTML
      <html>
        <body>
          <span class="s-status label">国家标准</span>
          <span class="s-status label">推荐性</span>
          <span class="s-status label">即将实施</span>
        </body>
      </html>
    END_HTML
    status = RelatonGb::GbScrapper.get_status doc
    expect(status.stage).to eq "published"
  end

  it "returns guidelines" do
    expect(RelatonGb::GbScrapper.send(:get_mandate, "DB11/Z 610-2008")).to eq "guidelines"
  end

  it "returns mandatory" do
    expect(RelatonGb::GbScrapper.send(:get_mandate, "GB 19855-2005")).to eq "mandatory"
  end
end
