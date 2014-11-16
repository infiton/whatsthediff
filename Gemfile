source 'https://rubygems.org'


gem 'rails', '4.1.7'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'  #Turbolinks is a pain in the buns

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

group :development do
	# gem 'spring'  #just for now, was causing some issues with installing foundation
	gem 'capistrano', '~> 3.1.0'
	gem 'capistrano-rails', '~> 1.1'
	gem 'capistrano-bundler'
    gem 'better_errors'
    gem "binding_of_caller" #dependancy for better_errors
end

group :development, :test do
	gem 'rspec-rails'
	gem 'factory_girl_rails'
end

group :test do
	gem 'faker'
	gem 'capybara'
	#gem 'gaurd-rspec', require: false
	gem 'launchy'
end

##For whatsthediff
gem 'mysql2'
gem 'foundation-rails'
gem 'awesome_print'
gem 'obfuscate_id', :git => 'https://github.com/namick/obfuscate_id.git'
gem 'mongoid', '~> 4'
gem 'bson_ext'
gem 'aasm'
gem 'draper', '~>1.3'