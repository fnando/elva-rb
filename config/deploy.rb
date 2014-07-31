require 'mina/bundler'
require 'mina/git'

set :domain, 'hellobits.com'
set :deploy_to, '/var/www/elva'
set :user, 'deploy'
set :repository, 'git@github.com:fnando/elva-rb.git'
set :branch, 'master'

set :shared_paths, ['.env']

task :setup => :environment do
  queue! %[touch "#{deploy_to}/shared/.env"]
  queue  %[echo "-----> Be sure to edit 'shared/.env'."]
end

task :restart => :environment do
  queue "touch #{deploy_to}/tmp/restart.txt"
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    to :launch do
      invoke :restart
    end
  end
end
