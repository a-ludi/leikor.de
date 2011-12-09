module FairDatesHelper
  def unless_su(string)
    superuser_logged_in? ? '' : string
  end
  
  def num_rows
    superuser_logged_in? ? @fair_dates.count + 2 : @fair_dates.count + 1
  end
end
