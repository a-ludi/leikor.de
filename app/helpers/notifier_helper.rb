# -*- encoding : utf-8 -*-

module NotifierHelper
  QUOTING_INDICATOR = '> '
  MAX_LINE_LENGTH = 78
  
  def mail_quoted text
    max_line_length = ::MAX_LINE_LENGTH - ::QUOTING_INDICATOR.length
    
    
  end
  
private
  
  def line_to_block line, length
    block = ''
    
    head, tail = split_at_word_boundary line, length
    while not tail.blank?
      block += head + $/
      
      head, tail = split_at_word_boundary tail, length
    end
    
    block += head
    
    block
  end
  
  def split_at_word_boundary line, length
    from = line.index /\S/
    to = from + length
    first_chars = line[from..to]
    cut_pos = unless to >= line.length
      first_chars.rindex /\S\b.+/
    else
      first_chars.rindex /\S/
    end
    cut_pos += from
    
    head = line[from..cut_pos]
    tail = line[cut_pos+1..-1]

    [head, tail]
  end
end
