#!/usr/bin/env ruby

# https://github.com/wycats/thor/wiki/Making-An-Executable

require "rubygems" # ruby1.9 doesn't "require" it though
require "thor"

class HerokuThor < Thor                                                
  package_name "Heroku"                                             
  map "-L" => :list   
  
  desc "start jekyl", "start jekyll"
  def jekyll
    exec "jekyll server --baseurl / --watch"
  end                                           
  
  desc "pull_and_restore DATABASE_NAME", "pull the latest database from heroku"   
  def pull_and_restore(database_name)
    exec "rake db:drop && rake db:create && heroku pgbackups:capture --expire && curl -o latest.dump `heroku pgbackups:url` && pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d #{database_name} latest.dump && rm latest.dump"
  end

  desc "backup database", "backs up the database"
  def backup_heroku
    exec "heroku pgbackups:capture --expire && curl -o latest.dump `heroku pgbackups:url`"
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

  desc "reset database", "reset database"  
  def reset
    exec "rake db:drop && rake db:create && rake db:migrate"
  end   

  desc "build assets", "build assets"
  def assets
    exec "rm -rf public/assets && RAILS_ENV=production rake assets:clean && RAILS_ENV=production rake assets:precompile"
  end     

  desc "clean assets", "clean assets"
  def clean_assets
    exec "rm -rf public/assets && RAILS_ENV=production rake assets:clean"
  end      
end

HerokuThor.start