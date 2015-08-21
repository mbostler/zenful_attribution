source 'https://rubygems.org'

source 'http://daruma-axys:8808' do
# # #   ### AXYS ###
  gem 'axys', '>= 0.3.10'
# # # TODO: update axys gem version!
# # # gem 'axys', '>= 0.3.2'
# # #   ### AXYS ###
end

gem 'gserver'
# gem 'axys', source: 'http://daruma-axys:8808'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'roo', '~> 2.0.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
  gem 'rspec-rails'  
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'rb-fsevent' #if `uname` =~ /Darwin/
  gem 'annotate'
  # gem 'axys', source: 'http://daruma-axys:8808'
end

