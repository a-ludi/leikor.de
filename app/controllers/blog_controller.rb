# -*- encoding : utf-8 -*-

class BlogController < ApplicationController
  include ReadersFromGroupsHelper
  
  before_filter :employee_required, :except => [:index, :show]
  before_filter :set_select_conditions, :only => [:index, :show]
  after_filter :mail_blog_post, :only => [:create, :update, :mail]
  
  def index
    @blog_posts = BlogPost.all(:conditions => @select_conditions)
    @title = "Blog"
    @stylesheets = %w(blog)
  end
  
  def show
    @blog_post = BlogPost.find params[:id], :conditions => @select_conditions
    @title = "#{@blog_post.title} (Blog)"
    @stylesheets = %w(blog)
  end

  def new
    @title = "Neuer Blogbeitrag"
    @stylesheets = %w(message form blog)
    @blog_post = flash[:blog_post] || BlogPost.new
    
    render :edit
  end

  def create
    @blog_post = @current_user.owned_blog_posts.create params[:blog_post]
    @blog_post.editor = @blog_post.author
    
    save_or_redirect_to new_blog_post_path
  end

  def edit
    @title = "Blogbeitrag bearbeiten"
    @stylesheets = %w(message form blog)
    @blog_post = flash[:blog_post] || BlogPost.find(params[:id])
  end

  def update
    @blog_post = BlogPost.find params[:id]
    @blog_post.update_attributes params[:blog_post]
    @blog_post.editor = @current_user
    
    save_or_redirect_to edit_blog_post_path(@blog_post)
  end
  
  def mail
    update_flag do
      params[:mail?] = 'yes'
    end
  end

  def publish
    update_flag do
      @blog_post.is_published = ! @blog_post.is_published
      @blog_post.save!
      
      #TODO use translations
      if @blog_post.is_published
        flash[:message].success "Blogbeitrag „#{@blog_post.title}“ wurde veröffentlicht."
      else
        flash[:message].success "Die Veröffentlichung vom Blogbeitrag „#{@blog_post.title}“ wurde zurückgezogen."
      end
    end
  end

  def destroy
    @blog_post = BlogPost.find params[:id]
    @blog_post.destroy
    
    flash[:message].success "Blogbeitrag „#{@blog_post.title}“ wurde gelöscht."
    
    redirect_to blog_posts_path
  end
  
  def readers
    @readers = readers_from_groups params[:groups]
    
    render :partial => 'readers', :object => @readers
  end

protected
  
  def update_flag
    @blog_post = BlogPost.find params[:id]
    
    yield
    
    respond_to do |format|
      format.html do
        redirect_to request.referer || blog_post_path(@blog_post)
      end
      
      format.js do
        flash[:message].clear!
        @no_message = true
        render :partial => 'flags', :locals => {:blog_post => @blog_post}
      end
    end
  end
  
  def set_select_conditions
    @select_conditions = if logged_in? Employee
      nil
    else
      {:is_published => true}
    end
  end
  
  def mail_blog_post
    if params[:mail?] == 'yes'
      @blog_post.readers.each { |user| Notifier.deliver_blog_post user, @blog_post }
      @blog_post.is_mailed = true
      @blog_post.save!
      
      flash[:message].success "Blogbeitrag „#{@blog_post.title}“ wurde gemailt." unless @no_message
    end
  end
  
  def save_or_redirect_to path
    if @blog_post.save
      redirect_to blog_post_path(@blog_post)
    else
      flash[:blog_post] = @blog_post
      
      redirect_to path
    end
  end
end
