module FairDatesHelper
  def unless_su(string)
    superuser_logged_in? ? '' : string
  end
  
  def num_rows
    (superuser_logged_in? ? @fair_dates.count + 2 : @fair_dates.count + 1) + (@fair_dates.count == 0 ? 1 : 0)
  end
  
  def nice_url(raw_url)
    raw_url[/^([a-zA-Z]+:\/\/)?(.*)\//, 2]
  end
end
