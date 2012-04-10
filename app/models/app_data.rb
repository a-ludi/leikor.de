# -*- encoding : utf-8 -*-

class AppData < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_inclusion_of :data_type, :in => [String, Fixnum, Float, Time].collect {|c| c.to_s}
  
  def self.[](name)
    record = AppData.find_by_name name.to_s
    return nil if record.nil?
    type_casted(record)
  end
  
  def self.[]=(name, value)
    record = AppData.find_or_create_by_name name.to_s
    record.value = value.to_s
    record.data_type = value.class.to_s
    record.save!
  end

private
  def self.type_casted(record)
    case record.data_type
      when 'String'
        return record.value
      when 'Fixnum'
        return record.value.to_i
      when 'Float'
        return record.value.to_f
      when 'Time'
        return record.value.to_time
      else
        raise ActiveRecord::RecordInvalid, record
    end
  end
end
