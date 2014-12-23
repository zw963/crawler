require 'singleton'

class Browser
  include Singleton

  def initialize
    unless eval(ENV['HEADLESS'].to_s) == false
      require 'headless'
      @headless = Headless.new
      @headless.start
    end

    if ENV['CHROME_PATH']
      Selenium::WebDriver::Chrome.path = ENV['CHROME_PATH']
      Watir.default_timeout = 10
      Watir::Dom::Wait.timeout = 5
      @browser = Watir::Browser.new(:chrome)
    else
      puts '没有设定 $CHROME_PATH 环境变量, 使用默认驱动 Firefox. (Chrome 会快很多!)'
      @browser = Watir::Browser.new
    end

    logger_with_puts "启动浏览器成功."
  end

  def method_missing(meth, *args)
    @browser.send(meth, *args)
  end

  def close
    logger_with_puts '正在关闭浏览器.'
    @browser.close unless @browser.nil?
    @headless.destroy unless @headless.nil?
  end
end
