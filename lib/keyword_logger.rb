require 'logger'

class KeywordLogger
  def self.keyword
    Thread.current['keyword'] || ENV['CRAWLER_SITE']
  end

  def self.logger
    logger = eval("Thread.current['#{keyword_symbol}_logger']")

    if logger
      logger
    else
      logger = Logger.new(log_name)
      logger.progname = "#{tags.join}"
      logger.info "\n\n" + '*'*100 + "\n启动 #{log_name}.\n" + '*'*100 + "\n"

      eval "Thread.current['#{keyword_symbol}_logger'] = logger"
    end

    logger.info "开始抓取 \033[0;33m#{keyword}\033[0m #{category}#{task}."

    logger
  end
end
