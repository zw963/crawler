require 'open-uri'
require 'cgi'
require 'csv'
require 'nokogiri'
require 'watir-webdriver'
require 'uri'
require 'json'
require 'erb'

require_relative 'browser'
require_relative 'keyword_logger'

module Common
  def site_yml_content
    File.read("#{home_directory}/config/site.yml")
  end

  def load_site_info
    site_info = YAML.load(ERB.new(site_yml_content).result(binding))[site]

    if site_info.is_a? Hash
      site_info.each_pair do |k, v|
        self.class.class_eval { define_method(k) { v } }
      end
    else
      logger_with_puts '未指定该站点 yml 信息, 请首先编辑 site.yml 细节.'
      exit
    end
  end

  def escaped_utf8_keyword
    CGI.escape($keyword)
  end

  def escaped_gbk_keyword
    CGI.escape($keyword.encode('gb2312', 'utf-8'))
  end

  def keywords_filename
    "#{home_directory}/config/keywords.txt"
  end

  def keyword_output
    "\033[0;33m#{$keyword}\033[0m"
  end

  def label(keyword)
    "\033[0;33m#{keyword}\033[0m #{category}#{task}"
  end

  def log_name
    log_name = "#{home_directory}/log/#{$keyword}/#{site}_#{tags.join('_')}.log"
    FileUtils.mkdir_p(File.dirname(log_name))
    log_name
  end

  def home_directory
    File.expand_path("#{__dir__}/..")
  end

  def browser
    @browser ||= Browser.instance
  end

  def hash_map
    {
      'product' => '产品',
      'image' => '图片',
      'detail' => '信息',
      'list' => '列表',
      'downloader' => '下载器'
    }
  end

  def product_id_attribute
    product_id_xpath[/@([\w\-_]+)/,1]
  end

  def pages_count
    element = search_page_content.css(search_page_pages_count_css)[0]
    # 如果找不到分页 CSS, 便假设只有一页.
    return 1 if element.nil?

    pages_count = element.text[/\d+/].to_i
    logger_with_puts "页面总数: #{pages_count}."
    pages_count
  end

  def logger
    logger = eval("$#{$keyword}_logger")

    if logger
      logger
    else
      eval "$#{$keyword}_logger = KeywordLogger.logger"
    end
  end

  def site
    ENV['SITE']
  end

  def category
    tags[1]
  end

  def task
    tags[2]
  end

  def logger_with_puts(message, level=:info)
    logger.send(level, message)
    puts message
  end

  def search_page_content
    content = instance_variable_get(:"@#{$keyword}_search_page_content")
    return content unless content.nil?

    begin
      browser.goto(search_page_url_with_pagination + '1')
      content = Nokogiri::HTML(browser.html)
      if content.blank?
        raise SocketError
      else
        instance_variable_set(:"@#{$keyword}_search_page_content", content)
      end
    rescue SocketError, Net::ReadTimeout
      logger_with_puts $!.message, :error
      retry
    end
  end

  def product_amount
    element = search_page_content.css(search_page_product_amount_css)[0]
    raise '请通过浏览器检查产品总数的 css 设定.' if element.nil?
    product_amount = element.text[/\d+/].to_i

    if product_amount == 0
      logger_with_puts "#{$keyword} 总数为 0, 取消抓取."
      throw :exit_capture
    else
      logger_with_puts "关键字: #{$keyword}, 总数: #{product_amount}"
    end
  end

  def keyword_csv_filename
    fail '不存在抓取关键字!' if $keyword.nil?

    keyword_csv_filename = "#{home_directory}/#{site}/#{$keyword}.csv"

    if test 's', keyword_csv_filename
      logger_with_puts "\033[0;33m#{keyword_csv_filename}\033[0m 文件存在, 跳过 !"
      throw :exit_capture
    end

    FileUtils.mkdir_p("#{home_directory}/#{site}")
    logger.info "打开 #{keyword_csv_filename}"

    keyword_csv_filename
  end

  private
  def tags
    @tags ||= $0.split('_').compact.map {|e| hash_map[e] }.compact
  end
end
