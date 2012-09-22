# -*- encoding : utf-8 -*-
require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase
  test_tested_files_checksum(
    ['app/models/blog_post.rb', 'c76e00c6e2bba05110fc4703b2be6235'],
    ['lib/readers_from_groups_extension.rb', '962de3b933562076b3ebabe858839536']
  )

  test "primary key should be public_id" do
    BlogPost.all.each do |blog_post|
      assert_equal blog_post.public_id, blog_post.id
    end
  end
  
  test "default ordering should be created_at DESC" do
    assert_equal blog_posts(:public_post, :mailed_post), BlogPost.all
  end
  
  test "body should be marked up with maruku" do
    assert_equal blog_posts(:mailed_post).body, "<p>This has lots of <strong>marked up</strong> and <em>fancy</em> text. You should know.</p>"
  end
  
  test "should belong to author" do
    assert_equal blog_posts(:mailed_post).author, users(:maxi)
  end
  
  test "should belong to editor" do
    assert_equal blog_posts(:mailed_post).editor, users(:maxi)
  end
  
  test "should have a public_id" do
    blog_posts(:mailed_post).public_id = ''
    
    assert_errors_on blog_posts(:mailed_post), :on => :public_id
  end
  
  test "should have a title" do
    blog_posts(:mailed_post).title = ''
    
    assert_errors_on blog_posts(:mailed_post), :on => :title
  end
  
  test "should have a body" do
    blog_posts(:mailed_post).body = ''
    
    assert_errors_on blog_posts(:mailed_post), :on => :body
  end
  
  test "should have a author" do
    blog_posts(:mailed_post).author = nil
    
    assert_errors_on blog_posts(:mailed_post), :on => :author
  end
  
  test "should have a editor" do
    blog_posts(:mailed_post).editor = nil
    
    assert_errors_on blog_posts(:mailed_post), :on => :editor
  end
  
  test "public_id should have the correct format" do
    blog_posts(:mailed_post).public_id = "wrong!format!"
    
    assert_errors_on blog_posts(:mailed_post), :on => :public_id
  end
  
  test "should generate public_id on create" do
    bp_title = 'This is a unique & cool title!'
    bp = BlogPost.create Hash[
        :title => bp_title,
        :body => 'Lots of funny text bits.',
        :author => users(:john),
        :editor => users(:john)]
    
    assert_equal bp.public_id, bp_title.url_safe
  end
  
  test "should include instance methods of ReadersFromGroupsHelper" do
    assert_includes BlogPost.instance_methods, :readers
    assert_includes BlogPost.instance_methods, :is_reader?
  end
end
