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

  def escaped_keyword
    CGI.escape(keyword)
  end

  def keyword_output
    "\033[0;33m#{keyword}\033[0m"
  end

  def label(keyword=name)
    "\033[0;31m#{keyword}\033[0m #{category}#{task}"
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
      'jd' => '京东',
      'tm' => '天猫',
      'product' => '产品',
      'picture' => '图片',
      'detail' => '信息',
      'list' => '列表'
    }
  end

  def site_yml_content
    File.read("#{home_directory}/site.yml")
  end

  def site_info
    return @site_info if @site_info

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

  def amount_css_path
    if site_info[1].empty?
      logger_with_puts '未指定页面数量 css path, 退出...'
      exit
    else
      site_info[1]
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
    tags[0]
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
