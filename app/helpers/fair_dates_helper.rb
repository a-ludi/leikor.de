module FairDatesHelper
  def unless_su(string)
    logged_in?(Employee) ? '' : string
  end
  
  def num_rows
    (logged_in?(Employee) ? @fair_dates.count + 2 : @fair_dates.count + 1) + (@fair_dates.count == 0 ? 1 : 0)
  end
  
  def nice_url(raw_url)
    raw_url[ /^([a-zA-Z]+:\/\/)?([^\/]+)/, 2]
  end
end
