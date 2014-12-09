require 'logger'

class KeywordLogger
  def self.logger(keyword)
    fail '启动 logger 需要首先指定 keyword!' if keyword.nil?
    @keyword = keyword

    logger = Logger.new(log_name)
    logger.progname = "#{tags.join}"
    logger.info "\n\n" + '*'*100 + "\n启动 #{log_name}.\n" + '*'*100 + "\n"

    logger.info "开始抓取 #{keyword_output} #{category}#{task}"
    puts "开始抓取 #{keyword_output} #{category}#{task}."

    logger
  end
end