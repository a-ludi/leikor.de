# encoding: utf-8

# This adds the url_safe method to String
module StringUrlSafeExtension
  URL_TRANSSCRIPTION = {
    'ä'   => 'ae',     'ö' => 'oe',
    'ü'   => 'ue',     'ß' => 'ss',
    '&'   => ' und ',  '€' => 'euro',
    '@'   => ' at ',   '°' => 'grad',
    '\\+' => ' plus ', 'µ' => 'my'}
  
  def url_safe
    safe_str = self.downcase
    URL_TRANSSCRIPTION.each { |match, replacement| safe_str.gsub! match, replacement }
    safe_str.gsub! /[^a-zA-Z0-9]+/, '-'
    safe_str.gsub! /[-]+/, '-'
    safe_str.gsub! /(^-|-$)/, ''
    
    safe_str.html_safe
  end
  
  def url_safe!
    self.replace self.url_safe
  end
end
 
class String
  include StringUrlSafeExtension
end
