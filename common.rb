require 'open-uri'
require 'cgi'
require 'csv'
require 'logger'
require 'nokogiri'
require 'watir-webdriver'
require 'uri'
require 'json'

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
      'product' => '产品',
      'picture' => '图片',
      'list' => '列表'
    }
  end

  def keyword_url
    CGI.escape(@keyword)
  end

  def logger
    fail '不存在抓取关键字!' if keyword.nil?

    iv = instance_variable_get(:"@#{keyword}_logger")

    if iv
      iv
    else
      FileUtils.mkdir_p("log/#{keyword}")
      tag_filename = "log/#{keyword}/#{tags.join('_')}.log"

      iv = Logger.new(tag_filename)
      iv.progname = "#{tags.join}"
      iv.info "\n\n" + '*'*100 + "\n启动 #{tag_filename} 抓取.\n" + '*'*100 + "\n"
      instance_variable_set(:"@#{keyword}_logger", iv)
      iv
    end
  end

  def product_amount
    iv = instance_variable_get(:"@#{keyword}_amount")

    if iv
      iv
    else
      iv = Nokogiri::HTML.
        parse(open("http://search.jd.com/Search?keyword=#{keyword_url}&enc=utf-8").read)
        .css('div.total span strong')
        .text.to_i
      logger.info "关键字: #{keyword}, 数量: #{iv}"

      if iv == 0
        logger.info "#{keyword} 数量为 0, 取消抓取."
        puts "#{keyword} 数量为 0, 取消抓取."
        throw :exit_capture
      end

      instance_variable_set(:"@#{keyword}_amount", iv)
      iv
    end
  rescue SocketError, HTTPError, URLError, Net::ReadTimeout
    logger.error $!.message
    puts $!.message
    retry
  end

  def site
    tags[0]
  end

  private
  def tags
    @tags ||= $0.split('_').compact.map {|e| hash_map[e] }.compact
  end
end
