require 'logger'

class KeywordLogger
  def self.logger(keyword)
    fail '启动 logger 需要首先指定 keyword!' if keyword.nil?

    FileUtils.mkdir_p("log/#{keyword}")
    tag_filename = "log/#{keyword}/#{tags.join('_')}.log"

    logger = Logger.new(tag_filename)
    logger.progname = "#{tags.join}"
    logger.info "\n\n" + '*'*100 + "\n启动 #{tag_filename} 抓取.\n" + '*'*100 + "\n"

    logger
  end
end
