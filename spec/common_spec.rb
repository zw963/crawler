require_relative '../lib/common'

describe Common do
  context '#site_info' do
    before do
      extend Common
      allow(self).to receive(:site_yml_content) { File.read(yml_file) }
      allow(self).to receive(:escaped_keyword) { '蒙牛' }
    end

    let(:yml_file) do
      yml = Tempfile.new('site_yml')
      yml.print <<-'HERE'
京东:
  - "http://search.jd.com/Search?keyword=<%=escaped_keyword%>&enc=utf-8"
  - div.total span strong
HERE
      yml.close
      yml.path
    end

    context 'when site is 京东' do
      before do
        allow(self).to receive(:site) { '京东' }
      end

      it 'should return site yml info' do
        expect(site_info).to eq ["http://search.jd.com/Search?keyword=蒙牛&enc=utf-8", "div.total span strong"]
      end

      it 'should return search_page_url' do
        expect(search_page_url).to eq "http://search.jd.com/Search?keyword=蒙牛&enc=utf-8"
      end

      it 'should return amount css path' do
        expect(amount_css).to eq "div.total span strong"
      end
    end

    context 'when site is 天猫' do
      before do

      end
      it 'site yml info is empty' do
        expect(self).to receive(:logger_with_puts).with('未指定站点 yml 信息, 退出...') { '未指定站点 yml 信息, 退出...' }
        expect { site_info }.to raise_error SystemExit
      end
    end
  end
end
