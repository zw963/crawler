require 'open-uri'
require 'cgi'
require 'csv'
require 'nokogiri'
require 'watir-webdriver'
require 'uri'
require 'json'
require_relative 'browser'
require_relative 'keyword_logger'
require 'erb'

module Common
  attr_accessor :keyword

  def escaped_utf8_keyword
    CGI.escape(keyword)
  end

  def escaped_gbk_keyword
    CGI.escape(keyword.encode('gb2312', 'utf-8'))
  end

  def keywords_filename
    "#{home_directory}/config/keywords.txt"
  end

  def keyword_output
    "\033[0;33m#{keyword}\033[0m"
  end

  def label(keyword=name)
    "\033[0;33m#{keyword}\033[0m #{category}#{task}"
  end

  def log_name
    log_name = "#{home_directory}/log/#{keyword}/#{tags.join('_')}.log"
    FileUtils.mkdir_p(File.dirname(log_name))
    log_name
  end

  def home_directory
    File.expand_path("#{__dir__}/..")
  end

  def browser
    @browser ||= Browser.browser(keyword)
  end

  def hash_map
    {
      'product' => '产品',
      'picture' => '图片',
      'detail' => '信息',
      'list' => '列表',
      'downloader' => '下载器'
    }
  end

  def site_yml_content
    File.read("#{home_directory}/config/site.yml")
  end

  def site_info
    site_info = YAML.load(ERB.new(site_yml_content).result(binding))[site]

    if site_info
      @site_info = site_info
    else
      logger_with_puts '未指定站点 yml 信息, 退出...'
      exit
    end
  end

  def search_page_url
    if site_info[0].empty?
      logger_with_puts '未指定搜索页面 url, 退出...'
      exit
    else
      site_info[0]
    end
  end

  def product_amount_css_path
    if site_info[1].empty?
      logger_with_puts '未指定产品总数 css path, 退出...'
      exit
    else
      site_info[1]
    end
  end

  def pages_count_css_path
    if site_info[2].empty?
      logger_with_puts '未指定页面数量 css path, 退出...'
      exit
    else
      site_info[2]
    end
  end

  def pages_count
    element = search_page_content.css(pages_count_css_path)[0]
    # 如果找不到分页 CSS, 便假设只有一页.
    return 1 if element.nil?

    element.text[/\d+/].to_i
  end

  def page_array
    if site_info[4].empty?
      logger_with_puts '未指定分页数组, 退出...'
      exit
    else
      eval site_info[4]
    end
  end

  def page_url
    if site_info[3].empty?
      logger_with_puts '未指定表示跳转页面的 url, 退出...'
      exit
    else
      site_info[3]
    end
  end

  def logger
    logger = eval("$#{keyword}_logger")

    if logger
      logger
    else
      eval("$#{keyword}_logger = KeywordLogger.logger(keyword)")
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

  private
  def tags
    @tags ||= $0.split('_').compact.map {|e| hash_map[e] }.compact
  end
end
