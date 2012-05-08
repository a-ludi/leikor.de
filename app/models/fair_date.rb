# -*- encoding: utf-8 -*-

class FairDate < ActiveRecord::Base
  marked_up_with_maruku :comment

  DATE_FORMAT = /^(?<day>\d{1,2})\.(?<month>\d{1,2})\.(?<year>\d{4})?$/
  DATE_FORMAT_IN_WORDS = '21.03.1981, 21.3.'

  validates_presence_of :from_date, :to_date, :name
  validates_markdown :comment
  validate :dates_are_dates
  
  def from_date= value;
    set_date_on :from_date, value
  end
  
  def to_date= value
    set_date_on :to_date, value
  end
  
protected
  
  def set_date_on attr, value
    self[attr] = parse_date(value) || value
  end
  
  def parse_date string
    return string  unless string.is_a? String
    
    match_data = string.match FairDate::DATE_FORMAT
    return if match_data.nil?
    
    make_date(match_data[:year], match_data[:month], match_data[:day])
  end
  
  def make_date(in_year, in_month, in_day)
    year = in_year.blank? ? Date.today.year : in_year.to_i
    month = in_month.to_i
    day = in_day.to_i
    
    date = Date.new year, month, day
    date += 1.year if in_year.blank? and date.past?
    
    return date
  end
  
  def dates_are_dates
    attrs = [:to_date, :from_date].map{ |attr| [attr, self[attr].is_a?(Date)] }
    
    return if attrs.map{|_, is_valid| is_valid}.all? 
    
    attrs.each do |attr, is_valid|
      errors.add attr, :invalid_format, :valid_format => FairDate::DATE_FORMAT_IN_WORDS unless is_valid
    end
  end
end
