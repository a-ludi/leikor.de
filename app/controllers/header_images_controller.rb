class HeaderImagesController < ApplicationController
  ssl_required_by_all_actions
  HASH_KEY_MAP = {'links' => 'left_header_image_path', 'rechts' => 'right_header_image_path'}
  HEADER_IMAGE_STYLE = :thumb
  before_filter :validate_id
  
  def update
    @article = Article.find_by_article_number params[:article_number]
    @hash_key = self.class::HASH_KEY_MAP[params[:id]]
    
    AppData[@hash_key] = @article.nil? ? '' : @article.picture.url(HEADER_IMAGE_STYLE)
    
    flash[:message].success "Seitenkopfbild (#{params[:id]}) aktualisiert."
    
    render :partial => 'layouts/push_message'
  end

private
  
  def validate_id
    raise ActiveRecord::RecordNotFound unless self.class::HASH_KEY_MAP.include? params[:id]
  end
end
