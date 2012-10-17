class ColorsController < ApplicationController
  def new
    @color = Color.new :hex => '#dd2200'
    
    @title = 'Neue Farbe (Artikelmerkmale)'
    @stylesheets = %w(message form article_features colorpicker)
    
    render :action => :edit
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
