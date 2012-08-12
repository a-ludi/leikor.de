# -*- encoding : utf-8 -*-
module AssertionsHelper::ActionMailerAssertions
  def assert_mail_sent(msg=nil)
    assert mail_count >= 1, ('expected staged mails; none found' || msg)
  end
  
  def assert_mails_sent(count=1, msg=nil)
    assert_equal count, mail_count, ('found #{mail_count} staged mails; expected #{count}' || msg)
  end
  
  def assert_mailed_to(addressee, msg=nil)
    unless addressee.respond_to? :each
      assert_includes latest_mail.to, addressee, msg
    else
      addressee.each {|addr| assert_includes latest_mail.to, addr, msg}
    end
  end
  
  def assert_mailed_from(sender, msg=nil)
    assert_includes latest_mail.from, sender, msg
  end
  
  def assert_mail_reply_to(replyee, msg=nil)
    assert_includes latest_mail.reply_to, replyee, msg
  end
  
  def assert_mail_body_match(regexp, msg=nil)
    assert_match regexp, latest_mail.body, msg
  end
  
private

  def deliveries
    mailer.deliveries
  end
  
  def latest_mail
    deliveries.first
  end
  
  def mail_count
    deliveries.count
  end
end
