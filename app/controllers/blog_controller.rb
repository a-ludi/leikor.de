# -*- encoding : utf-8 -*-

class BlogController < ApplicationController
  include ReadersFromGroupsExtension::ActionControllerMethods

  before_filter :employee_required, :except => [:index, :show]
  after_filter :mail_blog_post, :only => [:create, :update, :mail]

  def index
    @blog_posts = blog_posts
    @title = section_name
    @stylesheets = %w(blog Markdown)
  end

  def show
    begin
      @blog_post = blog_posts(params[:id])
      @title = "#{@blog_post.title} (#{section_name})"
      @stylesheets = %w(blog Markdown)
      @dont_link_title = true
    rescue ActiveRecord::RecordNotFound
      user_required or return

      flash[:message].error flash_message_text('missing')
      flash.keep

      redirect_to blog_posts_path
    end
  end

  def new
    @title = "Neuer Beitrag (#{section_name})"
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
    @title = "Beitrag bearbeiten (#{section_name})"
    @stylesheets = %w(message form blog)
    @blog_post = flash[:blog_post] || blog_posts(params[:id])
  end

  def update
    @blog_post = blog_posts(params[:id])
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

      flash[:message].success flash_message_text("success.published.#{@blog_post.is_published.to_s}",
          :title => @blog_post.title)
    end
  end

  def destroy
    @blog_post = blog_posts(params[:id])
    @blog_post.destroy

    flash[:message].success flash_message_text(:success, :title => @blog_post.title)
    flash.keep

    redirect_to blog_posts_path
  end

  def readers
    @readers = readers_from_groups(params[:groups]).all(:limit => 10).shuffle

    render :partial => 'readers', :object => @readers
  end

protected

  def section_name
    t(self.class.to_s.underscore, :scope => 'views.sections')
  end

  def flash_message_text(response, options={})
    options[:scope] = [:flash_message, :messages, self.class.to_s.underscore, action_name] unless
        options.include? :scope

    translate response, options
  end

  def update_flag
    @blog_post = blog_posts(params[:id])

    yield

    respond_to do |format|
      format.html do
        flash.keep

        redirect_to request.referer || blog_post_path(@blog_post)
      end

      format.js do
        flash[:message].clear!
        @no_message = true
        render :partial => 'flags', :locals => {:blog_post => @blog_post}
      end
    end
  end

  #TODO untidy. what to do about it?
  def blog_posts(id=nil)
    if logged_in? Employee
      if id.nil?
        BlogPost.all
      else
        BlogPost.find id
      end
    else
      if id.nil?
        BlogPost.all.select {|blog_post| blog_post.is_published? or blog_post.is_reader? @current_user }
      else
        blog_post = BlogPost.find id
        if blog_post.is_published? or blog_post.is_reader? @current_user
          return blog_post
        else
          raise ActiveRecord::RecordNotFound
        end
      end
    end
  end

  def mail_blog_post
    if params[:mail?] == 'yes'
      @blog_post.readers.each do |user|
        begin
          Notifier.deliver_blog_post user, @blog_post
        rescue StandardError => deliver_error
          @error_data = {:user => user, :blog_post => @blog_post}
          notify_about_exception(deliver_error)
        end
      end
      @blog_post.is_mailed = true
      @blog_post.save!

      flash[:message].success flash_message_text(:success, :title => @blog_post.title,
          :count => @blog_post.readers.count) unless @no_message
    end
  end

  def save_or_redirect_to path
    if @blog_post.save
      flash.keep

      redirect_to blog_post_path(@blog_post)
    else
      flash[:blog_post] = @blog_post
      flash.keep

      redirect_to path
    end
  end

  exception_data :error_data
  def error_data
    @error_data
  end
end
