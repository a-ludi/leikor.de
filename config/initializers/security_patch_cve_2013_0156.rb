# Treats an severe security issue (CVE-2013-0156) while Heroku does not support
# Rails 2.3.15.

ActionController::Base.param_parsers.delete(Mime::XML) 
