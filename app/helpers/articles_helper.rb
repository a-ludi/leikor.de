# -*- encoding : utf-8 -*-

module ArticlesHelper
  UNITS_PRECISION = {'mm' => 0, 'cm' => 0, 'dm' => 1, 'm' => 1}
  DIMENSION_LABEL = {:height => '<span title="Höhe">H</span>',
      :width => '<span title="Breite">B</span>', :depth => '<span title="Tiefe">T</span>'}
  
  def dimensions article
    dimensions = [article.height, article.width, article.depth]
    dimensions.map! {|v| "%.#{UNITS_PRECISION[article.unit]}f" % v unless v.blank?}
    
    "ca.&nbsp;#{dimensions.join_present('&times;')}&nbsp;#{article.unit}"
  end
  
  def dimensions_label article=nil
    labels = [(DIMENSION_LABEL[:height] if article.nil? or article.height?),
              (DIMENSION_LABEL[:width] if article.nil? or article.width?),
              (DIMENSION_LABEL[:depth] if article.nil? or article.depth?)]
    labels.join_present('&times;') + ':'
  end
  
  # Formats a +number+ into a currency string without the actual unit (e.g., 13.65). You can customize the format
  # in the +options+ hash.
  #
  # ==== Options
  # * <tt>:precision</tt>  -  Sets the level of precision (defaults to 2).
  # * <tt>:separator</tt>  - Sets the separator between the units (defaults to ".").
  # * <tt>:delimiter</tt>  - Sets the thousands delimiter (defaults to ",").
  def number_to_currency_value(number, options={})
    options.symbolize_keys!
 
    defaults  = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
    currency  = I18n.translate(:'number.currency.format', :locale => options[:locale], :raise => true) rescue {}
    defaults  = defaults.merge(currency)

    precision = options[:precision] || defaults[:precision]
    separator = options[:separator] || defaults[:separator]
    delimiter = options[:delimiter] || defaults[:delimiter]
    separator = '' if precision == 0

    begin
      number_with_precision(
          number,
          :precision => precision,
          :delimiter => delimiter,
          :separator => separator)
    rescue
      number
    end
  end
  
  def cancel_path article
    unless article.new_record?
      edit_article_path(article, :cancel => true)
    else
      new_article_path(:html_id => article.html_id, :cancel => true)
    end
  end
  
  def edit_image_on_click_handler
    "$(this).replaceSurroundedImage('#{image_path 'picture/thumb/in_work.png'}') && #{open_popup}"
  end
end
