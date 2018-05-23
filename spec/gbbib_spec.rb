require 'open-uri'
require 'net/http'

RSpec.describe Gbbib do
  it 'has a version number' do
    expect(Gbbib::VERSION).not_to be nil
  end

  it 'fetch national standard' do
    open_uri_stub 'GB/T 20223-2006', 'http://www.std.gov.cn/search/stdPage?q='
    open_uri_stub '5DDA8BA00FC618DEE05397BE0A0A95A7', 'http://www.std.gov.cn/gb/search/gbDetailed?id='
    gb_standard = Gbbib::GbBibliography.search 'GB/T 20223-2006'
    expect(gb_standard).to be_instance_of Gbbib::GbBibliographicItem
  end

  it 'fetch sector standard' do
    net_http_stub 'JB/T 13368-2018', 'http://www.std.gov.cn/hb/search/hbPage?searchText=', 'json'
    net_http_stub '6BC3AD94A1728ABCE05397BE0A0A5667', 'http://www.std.gov.cn/hb/search/stdHBDetailed?id='
    sec_standard = Gbbib::GbBibliography.search 'JB/T 13368-2018'
    expect(sec_standard).to be_instance_of Gbbib::GbBibliographicItem
  end

  it 'fetch social standard' do
    open_uri_stub 'T/GZAEPI 001-2018', 'http://www.ttbz.org.cn/Home/Standard?searchType=2&key='
    open_uri_stub '22746', 'http://www.ttbz.org.cn/StandardManage/Detail/'
    t_standard = Gbbib::GbBibliography.search 'T/GZAEPI 001-2018'
    expect(t_standard).to be_instance_of Gbbib::GbBibliographicItem
  end

  def open_uri_stub(ref, url, ext = 'html')
    expect(OpenURI).to receive(:open_uri).and_wrap_original do |m, *args|
      fetch_data(ref, ext) do
        expect(args[0]).to eq url + CGI.escape(ref.tr('-', [8212].pack('U')))
        m.call(args[0]).read
      end
    end
  end

  def net_http_stub(ref, url, ext = 'html')
    expect(Net::HTTP).to receive(:get).and_wrap_original do |m, *args|
      fetch_data(ref, ext) do
        expect(args[0]).to be_instance_of URI::HTTP
        expect(args[0].to_s).to eq URI(url + ref).to_s
        m.call args[0]
      end.read
    end
  end

  def file_path(ref, ext)
    file_name = ref.downcase.delete('/').gsub(/[\s-]/, '_')
    "spec/examples/#{file_name}.#{ext}"
  end

  def fetch_data(ref, ext)
    file = file_path ref, ext
    File.write file, yield unless File.exist? file
    File.open file
  end
end
