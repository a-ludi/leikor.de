require 'test_helper'

class MaterialTest < ActiveSupport::TestCase
  test_tested_files_checksum '0ab542d562ca483223696d4a0bb29c1e'
  
  def setup
    @material = materials(:teakwood)
  end
  
  test "should be orded by name ASC" do
    assert_equal materials(:linen, :teakwood), Material.all
  end

  test "should have a name" do
    refute_errors_on @material, :on => :name
    
    @material.name = nil
    
    assert_errors_on @material, :on => :name
  end

  test "name should be unique" do
    refute_errors_on @material, :on => :name
    
    @material = Material.create @material.attributes
    
    assert_errors_on @material, :on => :name
  end

  test "should have articles" do
    assert_respond_to @material, :articles
  end

  test "articles should only be addded once" do
    @articles = @material.articles
    @material.articles << @articles.first
    
    assert_equal @articles, @material.articles
  end

  test "should have a picture" do
    refute_errors_on @material, :on => :picture
    
    @material.picture = nil
    
    assert_errors_on @material, :on => :picture
  end

  test "picture should have a size of 32x32" do
    with_picture_file do |file|
      @geometry = Paperclip.run("identify", "-format %wx%h :file", :file => file.path).chomp
    end
    
    assert_equal "32x32", @geometry
  end

  test "picture should have a mime-type of image/gif" do
    with_picture_file do |file|
      @format = Paperclip.run("identify", "-format %m :file", :file => file.path).chomp
    end
    
    assert_equal "GIF", @format
  end

private
  
  def with_picture_file(material=@material)
    file = Tempfile::new('material')
    begin
      file.write material.picture_file
      file.read
      
      yield(file)
    ensure
      file.close
      file.unlink
    end
  end
end
