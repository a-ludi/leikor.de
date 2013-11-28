source 'https://rubygems.org'
ruby '1.9.2'

gem 'rails', '~> 2.3.18'
gem 'rake', '~> 0.9.2'
gem 'paperclip', '~> 2.4.5'
gem 'pg', '~> 0.14.0'
gem 'ssl_requirement', '~> 0.1.0'
gem 'bcrypt-ruby', '~> 3.0.1', :require => 'bcrypt'
gem 'acts-as-taggable-on', '~> 2.1.0'
gem 'haml', '~> 3.1.4'
gem 'maruku', '~> 0.6.0'
gem 'exception_notification', '~> 2.3.3.0'
gem 'delayed_job', :branch => 'v2.0', :git => 'git://github.com/collectiveidea/delayed_job.git'

group :production do
  gem 'unicorn', '~> 4.7.0' # embedded server for production 
end

group :development do
  gem 'libnotify', '~> 0.7.4'
  gem 'rb-inotify', '~> 0.8.8'
  gem 'guard-minitest', '~> 0.5.0'
  gem 'guard-bundler', '~> 1.0.0'
  gem 'spork', '~> 0.8.5'
  gem 'spork-testunit', '~> 0.0.8'
  gem 'mailtrap', '~> 0.2.1'
  gem 'foreman'
end
