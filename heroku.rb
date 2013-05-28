#!/usr/bin/env ruby

# https://github.com/wycats/thor/wiki/Making-An-Executable

require "rubygems" # ruby1.9 doesn't "require" it though
require "thor"

class HerokuThor < Thor                                                
  package_name "Heroku"                                             
  map "-L" => :list                                              
  
  desc "pull DATABASE_NAME", "pull the latest database from heroku"   
  def pull_and_restore(database_name)
    exec "heroku pgbackups:capture && curl -o latest.dump `heroku pgbackups:url`"
    exec "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d #{database_name} latest.dump"
    exec "rm latest.dump"
  end

  desc "push DATABASE_NAME", "pull the latest database to dropbox"  
  def push(database_name)
    exec "pg_dump -Fc --no-acl --no-owner -h localhost -U postgres #{database_name} > ~/Dropbox/Public/#{database_name}.dump"
  end  
end

HerokuThor.start