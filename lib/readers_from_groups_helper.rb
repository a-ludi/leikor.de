# -*- encoding: utf-8 -*-

module ReadersFromGroupsHelper
  # Junctor :except: außer, ausser, aber nicht, nicht, nicht aber, bis auf, aber nur, nur
  # Junctor :only: aber nur, nur
  JUNCTOR_EXCEPT_PATTERN = /\b(außer|ausser|nicht\s+aber|(aber\s+)?nicht|bis\s+auf)\b/
  JUNCTOR_ONLY_PATTERN = /\b(aber\s+)?(nur|lediglich)\b/
  JUNCTOR_PATTERN = Regexp.union JUNCTOR_EXCEPT_PATTERN, JUNCTOR_ONLY_PATTERN
  JUNCTOR_OPTIONS_HASH = {:except => {:exclude => true}, :only => {:any => true}}

  module InstanceMethods
    include ReadersFromGroupsHelper
    
    def readers
      return @readers[:users]  if not @readers.nil? and @readers[:groups] == groups
      
      @readers = {
          :users => readers_from_groups(groups),
          :groups => groups}
      
      @readers[:users]
    end
  end
  
  def readers_from_groups groups
    instructions = ReadersFromGroupsHelper.parse groups
    ReadersFromGroupsHelper.get_users_from instructions
  end

private

  def self.parse groups
    parts = extract_parts(groups || '')
    
    instructions = parts.map do |part|
      if part =~ JUNCTOR_EXCEPT_PATTERN
        [:junctor, :except]
      elsif part =~ JUNCTOR_ONLY_PATTERN
        [:junctor, :only]
      else
        [:group, part]
      end
    end
    
    compress instructions
  end
  
  def self.get_users_from instructions
    users = User.scoped({})
    instructions.reverse!
    
    while instruction = instructions.pop
      type, groups_or_name = instruction
      
      case type
        when :junctor
          junctor_name = groups_or_name
          type, groups_or_name = instructions.pop
          
          if type == :groups
            with_options = {:on => :groups}.merge JUNCTOR_OPTIONS_HASH[junctor_name]
            users = users.tagged_with groups_or_name, with_options
          else
            # ignore this junctor
            instructions.push [type, groups_or_name]
          end
        when :groups
          users = User.tagged_with groups_or_name, :on => :groups, :any => true
      end
    end
    
    return users
  end
  
  def self.extract_parts groups
    parts = groups.gsub(/\bund\b/, ',').split(',')
    parts.map! do |tag|
      sub_parts = tag.partition(JUNCTOR_PATTERN)
      sub_parts.map {|sub_part| sub_part.strip}
    end
    
    parts.flatten!
    parts.reject {|tag| tag.blank?}
  end
  
  def self.compress instructions
    aggregated_groups = []
    compressed_instructions = []
    
    instructions.each do |type, name|
      if type == :group
        aggregated_groups << name
      else
        compressed_instructions << [:groups, aggregated_groups]
        compressed_instructions << [:junctor, name]
        aggregated_groups = []
      end
    end
    
    compressed_instructions << [:groups, aggregated_groups] unless aggregated_groups.empty?
    compressed_instructions
  end
end
