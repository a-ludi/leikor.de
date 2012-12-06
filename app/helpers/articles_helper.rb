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
