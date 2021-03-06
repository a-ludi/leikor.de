# -*- encoding: utf-8 -*-

class BlogPost < ActiveRecord::Base
  set_primary_key :public_id
  default_scope :order => 'created_at DESC'
  
  marked_up_with_maruku :body
  belongs_to :author, :class_name => 'User'
  belongs_to :editor, :class_name => 'User'
  
  validates_presence_of :public_id, :title, :body, :author, :editor
  validates_format_of :public_id, :with => /^[a-z0-9-]+$/
  # TODO untested markdown, but how to?
  validates_markdown :body
  
  before_validation_on_create :set_public_id
  
  include ReadersFromGroupsExtension::ActiveRecordMethods

protected
  
  def set_public_id
    self[:public_id] ||= title.url_safe
  end
end
