worker_processes 1 # number of worker processes to spawn
worker_queues ["*"] # listen on all worker queues
worker_timeout 6 # timeout a worker
work_interval 1 # intervals to poll
working_directory File.expand_path(File.dirname(__FILE__))
pid File.expand_path(File.join(File.dirname(__FILE__),'test.pid'))
stderr_path File.expand_path(File.join(File.dirname(__FILE__),'test.err.log'))
stdout_path File.expand_path(File.join(File.dirname(__FILE__),'test.out.log'))
logfile File.expand_path(File.join(File.dirname(__FILE__),'test.log'))
preload_app true
daemonize true

setup do|forker|
  forker.options.verbose = true
end

# run in master
before_fork do
  puts "before_fork #{Process.pid}"
end

# run in worker
after_fork do
  puts "after_fork #{Process.pid}"
end
