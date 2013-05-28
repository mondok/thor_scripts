#!/usr/bin/env ruby

# https://github.com/wycats/thor/wiki/Making-An-Executable

require "rubygems" # ruby1.9 doesn't "require" it though
require "thor"

class HerokuThor < Thor                                                 # [1]
  package_name "Heroku"                                             # [2]
  map "-L" => :list                                              # [3]
  
  desc "pull DATABASE_NAME", "pull the latest database from heroku"   # [4]
  def pull_and_restore(database_name)
    %x(heroku pgbackups:capture && curl -o latest.dump `heroku pgbackups:url`)
    db_str = "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d #{database_name} latest.dump"
    exec db_str
    %x(rm latest.dump)
  end

  desc "pull DATABASE_NAME", "pull the latest database from heroku"   # [4]
  def push(database_name)
    db_str = "pg_dump -Fc --no-acl --no-owner -h localhost -U postgres #{database_name} > ~/Dropbox/Public/#{database_name}.dump"
    exec db_str
  end  
end

HerokuThor.start