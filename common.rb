require 'open-uri'
require 'cgi'
require 'csv'
require 'logger'
require 'nokogiri'
require 'watir-webdriver'
require 'uri'

module Common
  attr_accessor :keyword

  def browser
    unless ENV['CHROME_PATH']
      puts '没有设定 $CHROME_PATH 环境变量!'
      exit
    end

    Selenium::WebDriver::Chrome.path = ENV['CHROME_PATH']
    @browser ||= Watir::Browser.new(:chrome)
  end

  def hash_map
    {
      'jd' => '京东',
      'picture' => '图片',
      'list' => '列表'
    }
  end

  def keyword_url
    CGI.escape(@keyword)
  end

  def logger
    if @logger
      @logger
    else
      fail '不存在抓取关键字!' if keyword.nil?

      FileUtils.mkdir_p("log/#{keyword}")
      tag_filename = "log/#{keyword}/#{tags.join('_')}.log"

      @logger = Logger.new(tag_filename)
      @logger.progname = "抓取#{tags.join}\n\n"
      @logger.info "启动 $tag_filename 抓取."
      @logger
    end
  end

  def keyword_csv_filename
    fail '不存在抓取关键字!' if keyword.nil?

    FileUtils.mkdir_p(site)
    @csv_filename = "#{site}/#{keyword}.csv"
    logger.info "正在创建 #{@csv_filename}"
    @csv_filename
  end

  def site
    tags[0]
  end

  private
  def tags
    @tags ||= $0.split('_').compact.map {|e| hash_map[e] }.compact
  end
end
