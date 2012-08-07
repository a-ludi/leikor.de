# -*- encoding: utf-8 -*-

module FlashMessageHelper
  def flash_message_title
    if flash[:message].translate_title?
      translate flash[:message].title
    else
      flash[:message].title
    end
  end

  def log_flash_message
    logger.debug "[debug] flash[:message] = <#{flash[:message].inspect}>"
  end
end
