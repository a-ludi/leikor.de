# -*- encoding : utf-8 -*-

class ColorsController < ApplicationController
  def new
    @color = Color.new :hex => '#dd2200'
    @title = 'Neue Farbe (Artikelmerkmale)'
    @stylesheets = %w(message form article_features colorpicker)
    
    render :action => :edit
  end

  def create
    @color = Color.new params[:color]
    if @color.save
      redirect_to article_features_path
    else
      @title = 'Neue Farbe (Artikelmerkmale)'
      @stylesheets = %w(message form article_features colorpicker)
      render :action => :edit
    end
  end

  def edit
    @color = Color.from_param params[:id]
    @title = 'Farbe bearbeiten (Artikelmerkmale)'
    @stylesheets = %w(message form article_features colorpicker)
  end

  def update
    @color = Color.from_param params[:id]
    if @color.update_attributes params[:color]
      redirect_to article_features_path
    else
      redirect_to edit_color_path @color
    end
  end

  def destroy
    @color = Color.from_param params[:id]
    @color.destroy
    
    flash[:message].success "Die Farbe <b>#{@color.label}</b> wurde gelöscht."
  end

end
