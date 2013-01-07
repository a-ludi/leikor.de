class ArticleFeaturesController < ApplicationController
  def index
    @colors = Color.all
    @materials = Material.all
    
    @title = 'Artikelmerkmale'
    @stylesheets = %w(article_features)
  end
end
