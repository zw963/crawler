require 'open-uri'
require 'cgi'
require 'csv'
require 'logger'
require 'nokogiri'
require 'watir-webdriver'
require 'uri'
require 'json'
require_relative 'browser'

module Common
  attr_accessor :keyword

  def browser
    @browser ||= ::Browser.new.browser
  end

  def hash_map
    {
      'jd' => '京东',
      'product' => '产品',
      'picture' => '图片',
      'detail' => '详细',
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
      logger.info "关键字: #{keyword}, 页面报告数量: #{iv}"

      if iv == 0
        logger_with_puts "#{keyword} 数量为 0, 取消抓取."
        throw :exit_capture
      end

      instance_variable_set(:"@#{keyword}_amount", iv)
      iv
    end
  rescue SocketError, HTTPError, URLError, Net::ReadTimeout
    logger_with_puts $!.message, :error
    retry
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
