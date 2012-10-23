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
  
  def dimensions_label article
    labels = [(DIMENSION_LABEL[:height] if article.height?),
              (DIMENSION_LABEL[:width] if article.width?),
              (DIMENSION_LABEL[:depth] if article.depth?)]
    labels.join_present('&times;') + ':'
  end
end
