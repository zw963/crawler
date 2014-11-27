require 'logger'

class KeywordLogger
  def initialize(keyword)
    fail '不存在抓取关键字!' if keyword.nil?

    FileUtils.mkdir_p("log/#{keyword}")
    tag_filename = "log/#{keyword}/#{tags.join('_')}.log"

    @logger = Logger.new(tag_filename)
    @logger.progname = "#{tags.join}"
    @logger.info "\n\n" + '*'*100 + "\n启动 #{tag_filename} 抓取.\n" + '*'*100 + "\n"
  end

  def logger
    @logger
  end
end
