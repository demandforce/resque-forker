# Capistrano task for Resque::Forker.
#
# To use these tasks, require "resque/capistrano" at the top of the Capfile and
# associate your woker instances with the role 'worker'.
#
# Performs workers:reload after deploy:restart, workers:suspend before
# deploy:web:disable and workers:resume after deploy:web:enable.
Capistrano::Configuration.instance(:must_exist).load do
  after "deploy:restart", "workers:reload"
  before "deploy:web:disable", "workers:suspend"
  after "deploy:web:enabled", "workers:resume"

  namespace :workers do
    desc "Suspend all resque workers"
    task :suspend, :roles=>:worker do
      run "status workers | cut -d ' ' -f 4 | xargs kill -USR2"
    end
    desc "Resume all workers that have been paused"
    task :resume, :roles=>:worker do
      run "status workers | cut -d ' ' -f 4 | xargs kill -CONT"
    end
    desc "Reload all workers"
    task :reload, :roles=>:worker do
      run "reload workers"
    end
    desc "List Resque processes"
    task :pids, :roles=>:worker do
      puts capture("ps aux | grep [r]esque")
    end
  end
end
