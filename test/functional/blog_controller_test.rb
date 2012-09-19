require 'test_helper'

class BlogControllerTest < ActionController::TestCase
  tests_mailer Notifier

  test_tested_files_checksum(
    ['app/controllers/blog_controller.rb', 'e01268a00c3c5c3783f39264568304f1'],
    ['lib/readers_from_groups_extension.rb', '962de3b933562076b3ebabe858839536']
  )

  test "new create edit update mail publish destroy readers should require employee" do
    [:new, :create, :edit, :update, :mail, :publish, :destroy, :readers].each do |action|
      assert_before_filter_applied :employee_required, action
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
    https!
    get :index, {}, with_user
    
    assert_includes assigns(:blog_posts), blog_posts(:mailed_post)
  end
  
  test "show action without user" do
    @blog_post = blog_posts(:public_post)
    get :show, {:id => @blog_post.to_param}
    
    assert_equal @blog_post, assigns(:blog_post)
    assert_present assigns(:title)
    assert_respond_to assigns(:stylesheets), :each
    assert assigns(:dont_link_title), '@dont_link_title is not true'
    
    assert_raises ActiveRecord::RecordNotFound do
      @unavailable_blog_post = blog_posts(:mailed_post)
      get :show, {:id => @unavailable_blog_post.to_param}
    end
  end
  
  test "show action with user" do
    @blog_post = blog_posts(:mailed_post)
    https!
    get :show, {:id => @blog_post.to_param}, with_user
    
    assert_equal @blog_post, assigns(:blog_post)
    assert_present assigns(:title)
    assert_respond_to assigns(:stylesheets), :each
    assert assigns(:dont_link_title), '@dont_link_title is not true'
  end
  
  test "new action" do
    https!
    get :new, {}, with_user
    
    assert_present assigns(:title)
    assert_respond_to assigns(:stylesheets), :each
    assert assigns(:blog_post).new_record?, 'expected new record'
  end
  
  test "new action uses given blog post" do
    @new_blog_post = BlogPost.new :title => 'My New Post'
    https!
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
    https!
    get :edit, {:id => @blog_post.to_param}, with_user
    
    assert_present assigns(:title)
    assert_respond_to assigns(:stylesheets), :each
    assert_equal @blog_post, assigns(:blog_post)
  end
  
  test "edit action uses given blog post" do
    @blog_post = blog_posts(:mailed_post)
    @blog_post.title = 'New Title'
    https!
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
    https!
    get :mail, {:id => @blog_post.to_param}, with_user
    
    assert assigns(:blog_post).is_mailed, 'blog post not mailed'
    assert_present flash[:message]
    assert_mails_sent @blog_post.readers.count
  end
  
  test "mail action with js" do
    @blog_post = blog_posts(:public_post)
    https!
    xhr :post, :mail, {:id => @blog_post.to_param}, with_user
    
    assert @blog_post.reload.is_mailed, 'blog post not mailed'
    assert_empty flash[:message]
    assert_mails_sent @blog_post.readers.count
  end
  
  test "publish action with html, unpublished post and referer" do
    with_referer
    @blog_post = blog_posts(:mailed_post)
    https!
    get :publish, {:id => @blog_post.to_param}, with_user
    
    assert @blog_post.reload.is_published, 'blog post not published'
    refute_empty flash[:message]
    assert_redirected_to @referer
  end
    
  test "publish action with html and published post" do
    @blog_post = blog_posts(:public_post)
    https!
    get :publish, {:id => @blog_post.to_param}, with_user
    
    refute @blog_post.reload.is_published, 'blog post published'
    refute_empty flash[:message]
    assert_redirected_to blog_post_path(@blog_post)
  end
  
  test "destroy action" do
    @blog_post = blog_posts(:public_post)
    https!
    delete :destroy, {:id => @blog_post.to_param}, with_user
    
    assert_equal @blog_post, assigns(:blog_post)
    assert assigns(:blog_post).destroyed?, 'post not destroyed'
    refute_empty flash[:message]
    assert_redirected_to blog_posts_path
  end
  
  test "readers action" do
    @groups = "Holz bis auf Spielzeug"
    https!
    get :readers, {:groups => @groups}, with_user
    
    assert_includes assigns(:readers), users(:meyer)
    assert_includes assigns(:readers), users(:john)
    assert_template :partial => 'readers'
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
  
  test "blog_posts" do
    skip "TODO"
  end

private
  def post_create(options={})
    @author = users(:maxi)
    @before_owned_blog_post_count = @author.owned_blog_posts.count
    @blog_post = {
        :public_id => 'new-test-post',
        :title => "New Test Post",
        :body => "A very long and boring text.",
        :groups => '',
        :is_mailed => false,
        :is_published => false}
    @blog_post[:title] = '' if options[:with] == :errors
    https!
    post :create, {:blog_post => @blog_post}, with_user(@author)
  end
  
  def put_update(options={})
    @editor = users(:john)
    @before_edited_blog_post_count = @editor.edited_blog_posts.count
    @blog_post = blog_posts(:mailed_post)
    @changes = {:title => 'Neuer Titel'}
    @changes[:title] = '' if options[:with] == :errors
    https!
    put :update, {:id => @blog_post.to_param, :blog_post => @changes}, with_user(@editor)
  end
  
  
  def update_flag(format=:html)
    @blog_post = blog_posts(:mailed_post)
    block = Proc.new {flash[:message].success 'Non-empty Message!'; @called = true}
    
    https!
    call_method :update_flag, [], :params => {:id => @blog_post.to_param},
        :flash => {:block => block}, :session => with_user, :render => false,
        :xhr => (format == :js)
    
    assert @called, 'not called'
  end
end
