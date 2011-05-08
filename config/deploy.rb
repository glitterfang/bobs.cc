set :application, "bobs.cc"
set :repository,  "git@github.com:glitterfang/bobs.cc.git"
set :deploy_to, "/var/www"

set :scm, :git
server "bobs.cc", :app, :web, :db, :primary => true