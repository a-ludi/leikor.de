class AppData < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_inclusion_of :data_type, :in => [String.to_s, Integer.to_s, Float.to_s, DateTime.to_s, Time.to_s, Date.to_s]
  
  def self.[](name)
    record = AppData.find_by_name name
    type_casted(record.value, record.data_type)
  end
  
  def self.[]=(name, value)
    record = AppData.find_or_create_by_name name
    record.value = value.to_s
    record.data_type = value.class.to_s
    record.save!
  end

private
  def self.type_casted(value, type)
    case type
      when 'String'
        return value
      when 'Integer'
        return value.to_i
      when 'Float'
        return value.to_f
      when 'DateTime'
        return value.to_datetime
      when 'Time'
        return value.to_time
      when 'Date'
        return value.to_date
      else
        raise ActiveRecord::RecordInvalid("unknown type '#{type}' in model AppData")
    end
  end
end
