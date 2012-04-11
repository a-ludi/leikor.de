# -*- encoding : utf-8 -*-

class BlogController < ApplicationController
  before_filter :employee_required, :except => [:index, :show]
  
  def index
    @blog_posts = BlogPost.all :order => 'created_at DESC', :limit => 20
    @title = "Blog"
    @stylesheets = %w(blog)
  end
  
  def show
    @blog_post = BlogPost.find params[:id]
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
    
    if @blog_post.save
      redirect_to blog_post_path(@blog_post.public_id)
    else
      flash[:blog_post] = @blog_post
      
      redirect_to new_blog_post_path
    end
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
    
    if @blog_post.save
      redirect_to blog_post_path(@blog_post.public_id)
    else
      flash[:blog_post] = @blog_post
      
      redirect_to edit_blog_post_path(@blog_post.public_id)
    end
  end

  def destroy
  end

end
