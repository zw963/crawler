require 'open-uri'
require 'cgi'
require 'csv'
require 'nokogiri'
require 'watir-webdriver'
require 'watir-dom-wait'
require 'uri'
require 'json'
require 'erb'
require 'pathname'

require_relative 'browser'
require_relative 'keyword_logger'

module Common
  def site_yml_content
    File.read("#{home_directory}/config/site.yml")
  end

  def load_site_info
    content = YAML.load(ERB.new(site_yml_content).result(binding))
    site_hash = content[site]
    filename_map_hash = content['文件名映射']

    if site_hash.is_a? Hash and filename_map_hash.is_a? Hash
      site_hash.each_pair do |k, v|
        self.class.class_eval { define_method(k) { v } }
      end
      self.class.class_eval { define_method(:filename_map_hash) { filename_map_hash } }
    else
      logger_with_puts '未指定该站点 yml 信息, 请首先编辑 site.yml 细节.'
      exit
    end
  end

  def keyword_with_category
    "#{$keyword} #{ENV['CRAWLER_KEYWORD_CATEGORY']}"
  end

  def escaped_utf8_keyword
    CGI.escape(keyword_with_category)
  end

  def escaped_gbk_keyword
    CGI.escape(keyword_with_category.encode('gb2312', 'utf-8'))
  end

  def log_name
    log_name = "#{home_directory}/log/#{site}/#{keyword_name}_#{tags.join('_')}.log"
    FileUtils.mkdir_p(File.dirname(log_name))
    log_name
  end

  def home_directory
    File.expand_path("#{__dir__}/..")
  end

  def browser
    @browser ||= Browser.instance
  end

  def product_id_attribute
    product_id_xpath[/@([\w\-_]+)/, 1]
  end

  def pages_count
    element = search_page_content.css(search_page_pages_count_css)[0]
    if element.nil?
      # 如果找不到分页 CSS, 便假设只有一页.
      logger_with_puts "找不到分页 CSS, 假设页面总数为 1 页."
      1
    else
      pages_count = element.text[/\d+/].to_i
      logger_with_puts "当前分类: \033[0;33m#{keyword_with_category}\033[0m, 报告页面总数: #{pages_count}."
      pages_count
    end
  end

  def keyword_name
    fail '不存在抓取关键字!' if $keyword.nil?

    $keyword.tr('/', "\uff0f").rstrip
  end

  def keyword_symbol
    keyword_name.tr(' ', "\u00a0").tr('$', "\ufe69").tr('&', "\uff06").tr('-', "\uff0d")
  end

  def logger
    logger = eval("$#{keyword_symbol}_logger")

    if logger
      logger
    else
      eval "$#{keyword_symbol}_logger = KeywordLogger.logger"
    end
  end

  def site
    ENV['CRAWLER_SITE']
  end

  def site_directory
    "#{home_directory}/#{site}"
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
    content = instance_variable_get(:"@#{keyword_symbol}_search_page_content")
    return content unless content.nil?

    begin
      browser.reset!
      browser.goto(search_page_url_with_pagination + '1')
      content = Nokogiri::HTML(browser.html)
      if content.blank?
        raise SocketError
      else
        instance_variable_set(:"@#{keyword_symbol}_search_page_content", content)
      end
    rescue SocketError, Net::ReadTimeout
      logger_with_puts $!.message, :error
      retry
    end
  end

  def keyword_csv_filename
    keyword_csv_filename = "#{$keyword_directory}.csv"

    if test 's', keyword_csv_filename
      logger_with_puts "跳过 \033[0;32m#{keyword_csv_filename}\033[0m !"
      throw :exit_capture
    end

    FileUtils.mkdir_p(site_directory)
    logger.info "打开 #{keyword_csv_filename}"

    keyword_csv_filename
  end

  private
  def tags
    @tags ||= $0.split('_').compact.map {|e| filename_map_hash[e] }.compact
  end
end
