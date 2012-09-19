require "bundler/capistrano"
require "rvm/capistrano"

settings_yml_path = "config/settings.yml"
config = YAML::load(File.open(settings_yml_path))
application = config['deploy']["application"]
domain = config['deploy']["domain"]
port = config['deploy']["port"]

set :application, application
set :domain, domain
set :port, port

set :rails_env, "production"
set :deploy_to, "/srv/#{application}"
set :use_sudo, false
set :unicorn_instance_name, "unicorn"

set :scm, :git
set :repository, "https://github.com/openteam-tusur/plans.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :keep_releases, 7

set :bundle_gemfile,  "Gemfile"
set :bundle_dir,      File.join(fetch(:shared_path), 'bundle')
set :bundle_flags,    "--deployment --quiet --binstubs"
set :bundle_without,  [:development, :test]

role :web, domain
role :app, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc "Copy config files"
  task :config_app, :roles => :app do
    run "ln -s #{deploy_to}/shared/config/settings.yml #{release_path}/config/settings.yml"
    run "ln -s #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Precompile assets"
  task :compile_assets, :roles => :app do
    run "cd #{deploy_to}/current && RAILS_ENV=production bin/rake assets:precompile"
  end

  desc "HASK copy right unicorn.rb file"
  task :copy_unicorn_config do
    run "mv #{deploy_to}/current/config/unicorn.rb #{deploy_to}/current/config/unicorn.rb.example"
    run "ln -s #{deploy_to}/shared/config/unicorn.rb #{deploy_to}/current/config/unicorn.rb"
  end

  desc "Reload Unicorn"
  task :reload_servers do
    sudo "/etc/init.d/nginx reload"
    sudo "/etc/init.d/#{unicorn_instance_name} reload"
  end

  desc "Airbrake notify"
  task :airbrake do
    run "cd #{deploy_to}/current && RAILS_ENV=production TO=production bin/rake airbrake:deploy"
  end

  desc "Sunspot solr reindex"
  task :sunspot_reindex do
    run "cd #{deploy_to}/current && RAILS_ENV=production bin/rake sunspot:reindex"
  end

end

# remote database.yml
database_yml_path = "config/database.yml"
config = YAML::load(capture("cat #{deploy_to}/shared/#{database_yml_path}"))
adapter = config[rails_env]["adapter"]
database = config[rails_env]["database"]
db_username = config[rails_env]["username"]
host = config[rails_env]["host"]

#local database.yml
config = YAML::load(File.open(database_yml_path))
local_rails_env = 'development'
local_adapter = config[local_rails_env]["adapter"]
local_database = config[local_rails_env]["database"]
local_db_username = config[local_rails_env]["username"]

set :timestamp, Time.now.strftime("%Y-%m-%d-%H-%M")
namespace :db do
  desc "upload local database to remote server"
  task :export do
    if adapter == "postgresql"
      run_locally("pg_dump -O #{local_database} > tmp/#{local_database}-#{timestamp}.sql")
      upload "tmp/#{local_database}-#{timestamp}.sql", "#{deploy_to}/shared/database/#{local_database}-#{timestamp}.sql"
      sudo "/etc/init.d/#{unicorn_instance_name} stop"
      run "cd #{deploy_to}/current && RAILS_ENV=production bin/rake db:drop && RAILS_ENV=production bin/rake db:create"
      run "psql -d #{database} -h #{host} -U #{db_username} -f #{deploy_to}/shared/database/#{local_database}-#{timestamp}.sql"
      sudo "/etc/init.d/#{unicorn_instance_name} start"
    else
      puts "Cannot backup, adapter #{adapter} is not implemented for backup yet"
    end
  end
end

# deploy
after "deploy:finalize_update", "deploy:config_app"
after "deploy", "deploy:migrate"
after "deploy", "deploy:copy_unicorn_config"
after "deploy", "deploy:reload_servers"
after "deploy:reload_servers", "deploy:cleanup"
after "deploy", "deploy:airbrake"

# deploy:rollback
after "deploy:rollback", "deploy:reload_servers"