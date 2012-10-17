class MaterialsController < ApplicationController
  include Paperclip::Storage::Database::ControllerClassMethods
  downloads_files_for :material, :picture, :file_name => :name
  
  def new
    @material = Material.new
    
    @title = 'Neue Farbe (Artikelmerkmale)'
    @stylesheets = %w(message form article_features)
    
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
