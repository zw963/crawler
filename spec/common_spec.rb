require_relative '../lib/common'

describe Common do
  context '#load_site_info' do
    let(:yml_file) do
      yml = Tempfile.new('site_yml')
      yml.print <<-'HERE'
京东:
  search_page_url: 'http://search.jd.com/Search?keyword=<%= escaped_utf8_keyword %>&enc=utf-8'
  product_amount_css: 'div.total span strong'
  page_count_css: 'div#pagin-btm span.page-skip em'
  page_url: '&page='
  page_array: '(1..2*pages_count-1).step(2)'
  product_container_xpath: '//li[@sku]'
  product_detail_css: 'div#product-detail-1 ul.detail-list li'
  image_page_css: 'div#spec-n1'
HERE
      yml.close
      yml.path
    end

    before do
      extend Common
      allow(self).to receive(:site_yml_content) { File.read(yml_file) }
      allow(self).to receive(:escaped_utf8_keyword) { '蒙牛' }
    end

    context 'when site is 京东' do
      before do
        allow(self).to receive(:site) { '京东' }
        load_site_info
      end

      it 'should return search_page_url' do
        expect(search_page_url).to eq "http://search.jd.com/Search?keyword=蒙牛&enc=utf-8"
        expect(product_amount_css).to eq "div.total span strong"
        expect(page_count_css).to eq "div#pagin-btm span.page-skip em"
        expect(page_url).to eq "&page="
        expect(page_array).to eq "(1..2*pages_count-1).step(2)"
        expect(product_container_xpath).to eq "//li[@sku]"
        expect(product_detail_css).to eq "div#product-detail-1 ul.detail-list li"
        expect(image_page_css).to eq "div#spec-n1"
      end
    end

    context 'when site is 天猫' do
      before do
        allow(self).to receive(:site) { '天猫' }
        expect(self).to receive(:logger_with_puts).with('未指定该站点 yml 信息, 请首先编辑 site.yml 细节.')
      end
      it 'site yml info is empty' do
        expect { load_site_info }.to raise_error SystemExit
      end
    end
  end
end
