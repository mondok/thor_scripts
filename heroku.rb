#!/usr/bin/env ruby

# https://github.com/wycats/thor/wiki/Making-An-Executable

require "rubygems" # ruby1.9 doesn't "require" it though
require "thor"

class HerokuThor < Thor                                                
  package_name "Heroku"                                             
  map "-L" => :list                                              
  
  desc "pull_and_restore DATABASE_NAME", "pull the latest database from heroku"   
  def pull_and_restore(database_name)
    exec "rake db:drop && rake db:create && heroku pgbackups:capture --expire && curl -o latest.dump `heroku pgbackups:url` && pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d #{database_name} latest.dump && rm latest.dump"
  end

  desc "push DATABASE_NAME", "pull the latest database to dropbox"  
  def push(database_name)
    exec "pg_dump -Fc --no-acl --no-owner -h localhost -U postgres #{database_name} > ~/Dropbox/Public/#{database_name}.dump"
  end  

  desc "restore mysql from FILE_NAME", "restore a mysql database from a dump file"  
  def restore(file_name)
    exec "mysql -uroot < #{file_name}"
  end 

  desc "dump mysql DATABASE_NAME", "dump mysql database to file"  
  def dump(database_name)
    exec "mysqldump -uroot --databases #{database_name} >> #{database_name}.sql"
  end      
end

HerokuThor.start