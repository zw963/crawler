class Browser
  def initialize(non_headless=ENV['NON_HEADLESS'])
    return if non_headless

    require 'headless'
    @headless = Headless.new
    @headless.start
  ensure LoadError
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
    @browser.close
    @headless.destroy
  end
end
