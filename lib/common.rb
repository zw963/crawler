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

  def keyword_url
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
    "#{__dir__}/.."
  end

  def browser
    @browser ||= Browser.browser(keyword)
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
