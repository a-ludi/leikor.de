# -*- encoding : utf-8 -*-

class MaterialsController < ApplicationController
  include Paperclip::Storage::Database::ControllerClassMethods
  downloads_files_for :material, :picture, :file_name => :name
  
  def new
    @material = Material.new
    
    @title = 'Neues Material (Artikelmerkmale)'
    @stylesheets = %w(message form article_features)
    
    render :action => :edit
  end

  def create
    @material = Material.new params[:material]
    @material.picture = params[:material][:picture]
    if @material.save
      redirect_to article_features_path
    else
      @title = 'Neues Material (Artikelmerkmale)'
      @stylesheets = %w(message form article_features)
      render :action => :edit
    end
  end

  def edit
    @material = Material.from_param params[:id]
    @title = 'Material bearbeiten (Artikelmerkmale)'
    @stylesheets = %w(message form article_features)
  end

  def update
    @material = Material.from_param params[:id]
    @material.picture = params[:material][:picture] unless params[:material][:picture].blank?
    if @material.update_attributes params[:material]
      redirect_to article_features_path
    else
      redirect_to edit_material_path @material
    end
  end

  def destroy
    @material = Material.from_param params[:id]
    @material.destroy
    
    flash[:message].success "Das Material <b>#{@material.name}</b> wurde gelöscht."
  end

end
