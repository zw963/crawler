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
    product_container_xpath[/@([\w\-_]+)/,1]
  end

  def pages_count
    element = search_page_content.css(pages_count_css)[0]
    # 如果找不到分页 CSS, 便假设只有一页.
    return 1 if element.nil?

    element.text[/\d+/].to_i
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

  private
  def tags
    @tags ||= $0.split('_').compact.map {|e| hash_map[e] }.compact
  end
end
