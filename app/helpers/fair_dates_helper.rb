# -*- encoding: utf-8 -*-

module FairDatesHelper
  def unless_su(string)
    logged_in?(Employee) ? '' : string
  end
  
  def nice_url(raw_url)
    raw_url[ /^([a-zA-Z]+:\/\/)?([^\/]+)/, 2]
  end
end
