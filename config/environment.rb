# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.18' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'bcrypt'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.autoload_paths += %W( #{RAILS_ROOT}/extras )
  config.plugin_paths << "#{RAILS_ROOT}/lib/plugins"

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'paperclip', :version => '~> 2.4.5'
  config.gem 'bcrypt-ruby', :lib => 'bcrypt', :version => '~> 3.0.1'
  config.gem 'ssl_requirement', :version => '~> 0.1.0'
  config.gem 'acts-as-taggable-on', :version => '~> 2.1.0'
  config.gem 'haml', :version => '~> 3.1.4'
  config.gem 'maruku', :version => '~> 0.6.0'
  config.gem 'exception_notification', :version => '~> 2.3.3.0'
  config.gem 'delayed_job', :version => '~> 2.0.4'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Berlin'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :de
  config.action_controller.resources_path_names = {
    :new => 'neu',
    :edit => 'bearbeiten',
    :destroy => 'loeschen'
  }
  
  config.action_mailer.delivery_method = :smtp
end

Haml::Template.options[:format] = :html4
ExceptionNotification::Notifier.sender_address = '"Fehlerbericht" <fehler@leikor.de>'
ExceptionNotification::Notifier.exception_recipients = %w(webmaster@leikor.de)
ExceptionNotification::Notifier.sections << "blog_post_error"
