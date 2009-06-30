# Setup production dependencies
gem 'yfactorial-utility_scopes', :lib => 'utility_scopes', :source => 'http://gems.github.com/'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => "http://gems.github.com"
gem 'binarylogic-authlogic', :lib => 'authlogic', :source => 'http://gems.github.com/'

# Test dependencies
gem 'treetop'
gem 'dchelimsky-rspec', :lib => false, :source => 'http://gems.github.com'
gem 'dchelimsky-rspec-rails', :lib => false, :source => 'http://gems.github.com'
gem 'aslakhellesoy-cucumber', :lib => false, :source => 'http://gems.github.com'
gem 'webrat', :lib => false

# Plugins
plugin 'haml', :git => "git://github.com/nex3/haml.git"
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'
plugin "make_resourceful", :git => "git://github.com/hcatlin/make_resourceful.git"
plugin "paperclip", :git => "git://github.com/thoughtbot/paperclip.git"

# Make sure all the gems are packages with the source (and Rails)
rake "gems:install"
rake "gems:unpack"
rake "rails:freeze:gems"

# Basic bootstrapping/generation
generate :cucumber

# Some standard configuration
initializer 'will_paginate.rb', <<-CODE
ActiveRecord::Base.class_eval { def self.per_page; 10; end }
CODE

# TODO: Use wget to pull files from github?

# Standard rake db tasks
rakefile("db.rake") do
  <<-TASK
  namespace :db do
    desc "Drop the dbs, and does a full migrate to bring it back up"
    task :revert => ['db:drop', 'db:create', 'db:migrate']
  end
  TASK
end

# Common helper methods
# TODO: put in module for easier reuse
file "app/helpers/application_helper", <<-END
module ApplicationHelper

  # Print out all flash messages in a span of the same
  # class as the message type
  def flash_messages
    html = flash.collect do |type, message|
      content_tag(:div, message, :class => type)
    end
    flash.clear # Not sure why we have to manually do this sometimes
    html
  end
  
  # Are there any flash messages to display?
  def flash_messages?; flash.any?; end
  
  # Set the page title
  def page_title(title)
    content_for :page_title, title
  end
  
  # Set the html header title
  def head_title(title)
    content_for :head_title, title
  end
end
END

# Create a single migration that all mods go into until the first production release
generate :migration, "release001"

run "rm -rf test"
run "rm public/index.html"
run "cp config/database.yml config/example_database.yml"
run "git add *"
file ".gitignore", <<-END
.DS_Store
log/*.log
tmp
config/database.yml
*.tmproj
END
run "git add .gitignore"