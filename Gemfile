source 'http://rubygems.org'

group :assets do
  gem 'coffee-rails'
  gem 'compass-rails'
  gem 'jquery-rails',         '2.0.2'
  gem 'sass-rails'
  gem 'therubyracer'
  gem 'uglifier'
end

group :default do
  gem 'decent_exposure'
  gem 'default_value_for'
  gem 'draper'
  # NOTE: need for scopes support
  # TODO: remove git after v0.5.2 release
  gem 'enumerize',            :git => 'git://github.com/brainspec/enumerize'
  gem 'esp-views'
  gem 'grape'
  gem 'grape-entity'
  gem 'has_scope'
  gem 'inherited_resources', '1.4.1'
  gem 'memoist'
  gem 'nested_form'
  gem 'nokogiri',             :require => false
  gem 'openteam-commons',     '>= 0.2.3'
  gem 'paperclip-elvfs'
  gem 'progress_bar',         :require => false
  gem 'rails',                '~> 3.2.13'
  gem 'remotipart'
  gem 'russian'
  gem 'simple-navigation'
  gem 'simple_form'
  gem 'sso-auth'
  gem 'state_machine'
  gem 'timecop'
  gem 'wicked_pdf'
end

group :development do
  gem 'annotate',             '>= 2.5.0.pre'
  gem 'brakeman'
  gem 'hirb',                 :require => false
  gem 'quiet_assets'
  gem 'rails-erd'
  gem 'ruby-graphviz'
  gem 'openteam-capistrano',  :require => false
  gem 'capistrano-db-tasks', :git => 'git://github.com/sgruhier/capistrano-db-tasks'
  gem 'capistrano-unicorn'
end

group :test do
  gem 'fabrication'
  gem 'rspec-rails'
  gem 'shoulda-matchers',                          :require => false
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end
