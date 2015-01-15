require 'logger'

class KeywordLogger
  def self.logger
    fail '需要首先指定 keyword!' if $keyword.nil?

    logger = Logger.new(log_name)
    logger.progname = "#{tags.join}"
    logger.info "\n\n" + '*'*100 + "\n启动 #{log_name}.\n" + '*'*100 + "\n"

    logger.info "开始抓取 \033[0;33m#$keyword\033[0m #{category}#{task}."

    logger
  end
end
