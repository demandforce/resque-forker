worker_processes 2 # number of worker processes to spawn
worker_queues ["*"] # listen on all worker queues
worker_timeout 60 # timeout a worker
work_interval 3 # intervals to poll

working_directory "/var/www/apps/appname/current/"  # where to run daemonized workers
pid "/var/www/apps/appname/shared/pids/workers.pid" # master process pid
stderr_path "/var/www/apps/appname/shared/log/workers.stderr.log"
stdout_path "/var/www/apps/appname/shared/log/workers.stdout.log"
logfile "/var/www/apps/appname/shared/log/workers.log"
preload_app true
daemonize true

GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

setup do|forker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  defined?(Resque) and Resque.redis.client.disconnect

  if defined?(Rails) && Rails.env.development?
    forker.options.verbose = true
  else
    forker.logger   = defined?(Rails) ? Rails.logger : STDOUT
  end

end

# run in master
before_fork do
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  defined?(Resque) and Resque.redis.client.disconnect
end

# run in worker
after_fork do
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
  defined?(ResqueAppService) and ResqueAppService.init
end
