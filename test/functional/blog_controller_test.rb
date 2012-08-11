require 'test_helper'

class BlogControllerTest < ActionController::TestCase
  test_tested_files_checksum 'c76092fd87bdb5a57da9a28fdb69d9a4'
  
  test "new create edit update mail publish destroy readers should require employee" do
    [:new, :create, :edit, :update, :mail, :publish, :destroy, :readers].each do |action|
      assert_before_filter_applied :employee_required, action
    end
  end
  
  test "index show should set select_conditions" do
    [:index, :show].each do |action|
      assert_before_filter_applied :set_select_conditions, action
    end
  end
  
  test "create update mail should mail blog posts" do
    [:create, :update, :mail].each do |action|
      assert_after_filter_applied :mail_blog_post, action
    end
  end
  
  test "index action" do
    get :index
    
    assert_respond_to assigns(:blog_posts), :each
    refute_includes assigns(:blog_posts), blog_posts(:mailed_post)
    refute_empty assigns(:title)
    assert_respond_to assigns(:stylesheets), :each
  end
  
  test "index action with user" do
    get :index, {}, with_user
    
    assert_includes assigns(:blog_posts), blog_posts(:mailed_post)
  end
  
  test "show action without user" do
    @blog_post = blog_posts(:public_post)
    get :show, {:id => @blog_post.to_param}
    
    assert_equal @blog_post, assigns(:blog_post)
    assert_present assigns(:title)
    assert_respond_to assigns(:stylesheets), :each
    
    assert_raises ActiveRecord::RecordNotFound do
      @unavailable_blog_post = blog_posts(:mailed_post)
      get :show, {:id => @unavailable_blog_post.to_param}
    end
  end
  
  test "show action with user" do
    @blog_post = blog_posts(:mailed_post)
    get :show, {:id => @blog_post.to_param}, with_user
    
    assert_equal @blog_post, assigns(:blog_post)
    assert_present assigns(:title)
    assert_respond_to assigns(:stylesheets), :each
  end
  
  test "new action" do
    get :new, {}, with_user
    
    assert_present assigns(:title)
    assert_respond_to assigns(:stylesheets), :each
    assert assigns(:blog_post).new_record?, 'expected new record'
  end
  
  test "new action uses given blog post" do
    @new_blog_post = BlogPost.new :title => 'My New Post'
    get :new, {}, with_user, {:blog_post => @new_blog_post}
    
    assert_equal @new_blog_post, assigns(:blog_post)
  end
  
  test "successful create action" do
    post_create
    
    assert_equal @blog_post[:title], assigns(:blog_post).title
    assert_equal @before_owned_blog_post_count + 1, @author.owned_blog_posts.count
    assert_equal @author, assigns(:blog_post).editor
    assert_redirected_to blog_post_path(assigns(:blog_post))
  end

  test "failed create action" do
    post_create :with => :errors
    
    assert_includes flash, :blog_post
    assert_redirected_to new_blog_post_path
  end

  test "edit action" do
    @blog_post = blog_posts(:mailed_post)
    get :edit, {:id => @blog_post.to_param}, with_user
    
    assert_present assigns(:title)
    assert_respond_to assigns(:stylesheets), :each
    assert_equal @blog_post, assigns(:blog_post)
  end
  
  test "edit action uses given blog post" do
    @blog_post = blog_posts(:mailed_post)
    @blog_post.title = 'New Title'
    get :edit, {:id => @blog_post.to_param}, with_user, {:blog_post => @blog_post}
    
    assert_equal @blog_post, assigns(:blog_post)
  end
  
  test "successful update action" do
    put_update
    
    assert_equal @changes[:title], assigns(:blog_post).title
    assert_equal @editor, assigns(:blog_post).editor
    assert_equal @before_edited_blog_post_count + 1, @editor.edited_blog_posts.count
    assert_redirected_to blog_post_path(assigns(:blog_post))
  end
  
  test "failed update action" do
    put_update :with => :errors
    
    assert_equal @changes[:title], assigns(:blog_post).title
    assert_equal @editor, assigns(:blog_post).editor
    assert_equal @before_edited_blog_post_count, @editor.edited_blog_posts.count
    assert_includes flash, :blog_post
    assert_redirected_to edit_blog_post_path(@blog_post)
  end
  
  test "mail action with html" do
    @blog_post = blog_posts(:public_post)
    get :mail, {:id => @blog_post.to_param}, with_user
    
    assert @blog_post.reload.is_mailed, 'blog post not mailed'
    refute_empty flash[:message]
    skip 'TODO assert mails are sent'
  end
  
  test "mail action with js" do
    @blog_post = blog_posts(:public_post)
    xhr :post, :mail, {:id => @blog_post.to_param}, with_user
    
    assert @blog_post.reload.is_mailed, 'blog post not mailed'
    assert_empty flash[:message]
    skip 'TODO assert mails are sent'
  end
  
  test "publish action with html, unpublished post and referer" do
    with_referer
    @blog_post = blog_posts(:mailed_post)
    get :publish, {:id => @blog_post.to_param}, with_user
    
    assert @blog_post.reload.is_published, 'blog post not published'
    refute_empty flash[:message]
    assert_redirected_to @referer
  end
    
  test "publish action with html and published post" do
    @blog_post = blog_posts(:public_post)
    get :publish, {:id => @blog_post.to_param}, with_user
    
    refute @blog_post.reload.is_published, 'blog post published'
    refute_empty flash[:message]
    assert_redirected_to blog_post_path(@blog_post)
  end
  
  test "destroy action" do
    @blog_post = blog_posts(:public_post)
    delete :destroy, {:id => @blog_post.to_param}, with_user
    
    assert_equal @blog_post, assigns(:blog_post)
    assert assigns(:blog_post).destroyed?, 'post not destroyed'
    refute_empty flash[:message]
    assert_redirected_to blog_posts_path
  end
  
  test "readers action" do
    skip 'TODO assign users to groups in fixtures'
    @groups = ''
    get :readers, {:groups => @groups}
  end

  test "update_flag with html without referer" do
    update_flag :html
    
    assert_equal @blog_post, assigns(:blog_post)
    refute_empty flash[:message]
    assert_redirected_to blog_post_path(@blog_post)
  end
  
  test "update_flag with html and referer" do
    with_referer
    update_flag :html
    
    assert_equal @blog_post, assigns(:blog_post)
    refute_empty flash[:message]
    assert_redirected_to @referer
  end
  
  test "update_flag with js" do
    update_flag :js
    
    assert_equal @blog_post, assigns(:blog_post)
    assert_empty flash[:message]
    assert assigns(:no_message), 'no_message set to true'
    assert_template :partial => 'flags'
  end

  test "set_select_conditions with employee" do
    get :index, {}, with_user(:john) # calls set_select_conditions
    
    assert_nil assigns(:select_conditions)
  end
  
  test "set_select_conditions without employee" do
    get :index, {}, with_user(:moritz) # calls set_select_conditions
    
    assert_kind_of Hash, assigns(:select_conditions)
  end
  
private
  def post_create(options={})
    @author = users(:max)
    @before_owned_blog_post_count = @author.owned_blog_posts.count
    @blog_post = {
        :public_id => 'new-test-post',
        :title => "New Test Post",
        :body => "A very long and boring text.",
        :groups => '',
        :is_mailed => false,
        :is_published => false}
    @blog_post[:title] = '' if options[:with] == :errors
    post :create, {:blog_post => @blog_post}, with_user(@author)
  end
  
  def put_update(options={})
    @editor = users(:john)
    @before_edited_blog_post_count = @editor.edited_blog_posts.count
    @blog_post = blog_posts(:mailed_post)
    @changes = {:title => 'Neuer Titel'}
    @changes[:title] = '' if options[:with] == :errors
    put :update, {:id => @blog_post.to_param, :blog_post => @changes}, with_user(@editor)
  end
  
  
  def update_flag(format=:html)
    @blog_post = blog_posts(:mailed_post)
    block = Proc.new {flash[:message].success 'Non-empty Message!'; @called = true}
    
    call_method :update_flag, [], :params => {:id => @blog_post.to_param},
        :flash => {:block => block}, :session => with_user, :render => false,
        :xhr => (format == :js)
    
    assert @called, 'not called'
  end
end
