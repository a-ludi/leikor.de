# -*- encoding : utf-8 -*-
module AssertionsHelper::SslAssertions
  def assert_ssl_required(msg=nil)
    with_saved_https_state do
      https! false
      
      yield
      
      if redirect? and to_https?
        pass
      else
        msg = message(msg) do
          if redirect?
            build_message 'Expected redirect to https location, but was <?>',
              @response['Location']
          else
            'Expected redirect'
          end
        end
        
        flunk msg
      end
    end
  end
  
  def assert_ssl_allowed(msg=nil)
    with_saved_https_state do
      https!
      
      yield
      
      if not redirect? or to_https?
        pass
      else
        msg = message(msg) { build_message 'Expected no redirect or redirect to https location, but was <?>',
            @response['Location'] }
        flunk msg
      end
    end
  end
  
  def assert_ssl_denied(msg=nil)
    with_saved_https_state do
      https!
      
      yield
      
      if redirect? and to_http?
        pass
      else
        msg = message(msg) do
          if redirect?
            build_message 'Expected redirect to http location, but was <?>', @response['Location']
          else
            'Expected redirect'
          end
        end
        flunk msg
      end
    end
  end
  
  def refute_ssl_required(msg=nil)
    with_saved_https_state do
      https! false
      
      yield
      
      if not redirect? or to_http?
        pass
      else
        msg = message(msg) { build_message 'Expected no redirect or redirect to http location, but was <?>',
            @response['Location'] }
        flunk msg
      end
    end
  end
  
private
  
  def with_saved_https_state
    https_state = @request.env['HTTPS']
    yield
    @request.env['HTTPS'] = https_state
  end
  
  def redirect?
    @response.include? 'Location'
  end
  
  def to_https?
    @response['Location'].start_with? 'https:'
  end
  
  def to_http?
    @response['Location'].start_with? 'http:'
  end
end
