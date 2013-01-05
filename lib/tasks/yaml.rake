# -*- encoding : utf-8 -*-

namespace :db do
  namespace :file do
    namespace :load do
      desc 'Load a YAML file into the database using ActiveRecord. Records where saving failed are written to FAILED with a error report.'
      task :yml, [:filename] => [:environment] do |t, args|
        loader = YamlLoader.new(args.filename)
        loader.process_entries
        YamlReporter.new(ENV['FAILED'], loader.failed).write unless ENV['FAILED'].blank?
        ConsoleReporter.new(loader.succeeded, loader.failed).write
      end
    end
  end
end

private

class YamlLoader
  require 'yaml'
  require 'open-uri'
  
  def initialize(filename)
    @succeeded = {}
    @failed = {}
    @yaml = YAML.load(open(filename) {|f| f.read})
  end
  
  attr_reader :failed, :succeeded
  
  def process_entries
    @yaml.each do |identifier, record_data|
      @identifier = identifier
      @record_data = record_data.update('_errors' => [])
      
      begin
        get_model
        update_attributes if @record_data.include? 'update_attributes'
      rescue FieldMissingError, ActiveRecord::ActiveRecordError => error
        add_error "#{error.class.to_s}: #{error.to_s}"
      rescue => error
        add_error "#{error.class.to_s}: #{error.to_s}\n  #{error.backtrace.join('\n  ')}"
      ensure
        register_record
      end
    end
  end

protected
  
  def get_model
    field_missing! 'class' unless @record_data.include? 'class'
    @model = @record_data['class'].constantize
  end
  
  def register_record
    if @succeeded.include? @identifier or @failed.include? @identifier
      $stderr.puts "Warning: ambigious identifier `#{@identifier}`"
    end
    
    if @record_data['_errors'].empty?
      @succeeded[@identifier] = @record_data
    else
      @failed[@identifier] = @record_data
    end
  end
  
  def update_attributes
    field_missing! 'conditions' unless @record_data.include? 'conditions'
    @record = @model.find :first, :conditions => @record_data['conditions']
    raise ActiveRecord::RecordNotFound if @record.nil?
    
    before_upate if @record_data.include? 'before_upate'
    @record.update_attributes! @record_data['update_attributes']
  end
  
  def before_upate
    context = CallbackContext.new(@identifier, @record_data, @record)
    context.binding.eval @record_data['before_upate'], @identifier
  end
  
  def add_error(descriptions)
    if descriptions.is_a? Array
      @record_data['_errors'] += descriptions
    else
      @record_data['_errors'] << descriptions
    end
  end
  
  def field_missing!(field_name)
    raise FieldMissingError, "no field `#{field_name}` given"
  end
end

class FieldMissingError < StandardError
end

class CallbackContext
  def initialize(identifier, record_data, record)
    @identifier, @record_data, @record = identifier, record_data, record
  end
  
  alias :kernel_binding :binding
  def binding
    kernel_binding
  end
end

class YamlReporter
  def initialize(file_name, data)
    @file_name = file_name
    @data = data
  end
  
  def write
    begin
      open(@file_name, 'w') {|f| f.write @data.to_yaml }
    rescue => error
      $stderr.puts "#{error.class.to_s}: #{error.to_s}"
      $stderr.puts "Writing contents to standard errror:"
      $stderr.puts "# BEGIN file contents"
      $stderr.puts @data.to_yaml
      $stderr.puts "# END file contents"
    end
  end
end

class ConsoleReporter
  def initialize(succeeded, failed)
    @succeeded = succeeded
    @failed = failed
  end
  
  def write
    puts "Result: #{@succeeded.count} successes, #{@failed.count} failures"
  end
end
