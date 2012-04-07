# -*- encoding: utf-8 -*-

class FairDate < ActiveRecord::Base
  DATE_FORMAT = /^(?<day>\d{1,2})\.(?<month>\d{1,2})\.(?<year>(\d{4}|\d{2}))?$/
  FORMAT_ERROR = "hat ein falsches Format. Gültig sind Angaben wie z.B. 24.12.2011, 24.12.11 oder 24.12."
  validates_presence_of :from_date, :to_date, :name
  
  def from_date= value
    set_date_on :from_date, value, Date.today
  end
  
  def to_date= value
    set_date_on :to_date, value, Date.today + 1.month
  end
  
private
  
  def set_date_on attr, value, default_value
    catch :format_error do
      self[attr] = case value
        when Date then value
        else parse_date value.to_s
      end
    end
    
    self[attr] = default_value
    self.errors.add attr, FairDate::FORMAT_ERROR
  end
  
  def parse_date string
    match_data = string.match FairDate::DATE_FORMAT
    throw :format_error if match_data.nil?
    
    year = match_data[:year] || Date.today.year
    month = match_data[:month]
    day = match_data[:day]
    
    date = Date.new year.to_i, month.to_i, day.to_i
    date += 1.year  if date.past?
  end
end
