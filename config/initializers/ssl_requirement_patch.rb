# encoding: utf-8

# This fixes the bug in:
# /ssl_requirement-0.1.0/lib/ssl_requirement.rb:49
SslRequirement # get Rails to autoload the module before patching
module SslRequirement
private
  
  def ensure_proper_protocol
    if ssl_allowed? and not ssl_required?
      return true
    elsif ssl_required? && !request.ssl?
      redirect_to "https://" + request.host + request.request_uri
      flash.keep
      return false
    elsif request.ssl? && !ssl_required?
      redirect_to "http://" + request.host + request.request_uri
      flash.keep
      return false
    end
  end
end
