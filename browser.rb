class Browser
  def initialize(keyword, non_headless=ENV['NON_HEADLESS'])
    fail '启动 browser 需要首先指定 keyword!' if keyword.nil?
    @keyword = keyword

    return if non_headless

    require 'headless'
    @headless = Headless.new
    @headless.start
  ensure
    logger_with_puts "正在打开浏览器"

    if ENV['CHROME_PATH']
      Selenium::WebDriver::Chrome.path = ENV['CHROME_PATH']
      @browser = Watir::Browser.new(:chrome)
    else
      puts '没有设定 $CHROME_PATH 环境变量, 使用默认驱动 Firefox. (Chrome 会快很多!)'
      @browser = Watir::Browser.new
    end
  end

  def browser
    @browser
  end

  def close
    logger_with_puts '正在关闭浏览器'
    @browser.close unless @browser.nil?
    @headless.destroy unless @headless.nil?
  end
end