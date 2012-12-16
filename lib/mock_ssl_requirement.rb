# This module mocks the SslRequirement module from the gem with the same name,
# making it functionless. This is itended to aid easy development.
module MockSslRequirement
  def self.included(controller)
    controller.extend(ClassMethods)
  end

  module ClassMethods
    def ssl_required(*actions)
    end

    def ssl_allowed(*actions)
    end
  end
end
