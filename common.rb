require 'open-uri'
require 'cgi'
require 'csv'
require 'nokogiri'
require 'watir-webdriver'
require 'uri'
require 'json'
require_relative 'browser'
require_relative 'keyword_logger'

module Common
  attr_accessor :keyword

  def keyword_output
    "\033[0;33m#{@keyword}\033[0m"
  end

  def browser
    @browser ||= Browser.new(keyword, true).browser
  end

  def hash_map
    {
      'jd' => '京东',
      'product' => '产品',
      'picture' => '图片',
      'detail' => '信息',
      'list' => '列表'
    }
  end

  def keyword_url
    CGI.escape(keyword)
  end

  def logger
    iv = instance_variable_get(:"@#{keyword}_logger")

    if iv
      iv
    else
      instance_variable_set(:"@#{keyword}_logger", KeywordLogger.new(keyword).logger)
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
