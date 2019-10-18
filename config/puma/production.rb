# frozen_string_literal: true

workers Integer(ENV.fetch('WEB_CONCURRENCY', 3))
threads_count = Integer(ENV.fetch('MAX_THREADS', 5))
threads(threads_count, threads_count)

preload_app!

if ENV['ANSIBLE_PROVISIONED']
  shared_path = "#{ENV['APP_DIR']}/shared"
  bind "unix://#{shared_path}/tmp/sockets/puma.sock"
  state_path "#{shared_path}/tmp/pids/puma.state"
  pidfile "#{shared_path}/tmp/pids/puma.pid"
  stdout_redirect "#{shared_path}/log/puma.access.log",
                  "#{shared_path}/log/puma.error.log",
                  true
else
  port ENV.fetch('PORT', 3000)
end

environment ENV.fetch('RACK_ENV', 'development')



bind  "unix:///var/www/italiaauto/shared/tmp/sockets/puma.sock"
pidfile "/var/www/italiaauto/shared/tmp/pids/puma.pid"
state_path "/var/www/italiaauto/shared/tmp/sockets/puma.state"
directory "/var/www/italiaauto/current"

workers 2
threads 1,2

daemonize true

activate_control_app 'unix:///var/www/italiaauto/shared/tmp/sockets/pumactl.sock'
prune_bundler

plugin :tmp_restart


before_fork do
  ::ActiveRecord::Base.connection_pool.disconnect!
  ::I18n.backend.send(:init_translations) unless ::I18n.backend.initialized?
end

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
