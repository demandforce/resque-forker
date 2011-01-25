require 'optparse'
require "resque/forker"

module Resque

  class Master
    attr_reader :options

    def worker_processes(count)
      @options[:worker_processes] = count
    end

    def worker_queues(queues)
      @options[:worker_queues] = queues
    end

    def worker_timeout(timeout)
      @options[:worker_timeout] = timeout
    end

    def work_interval(interval)
      @options[:work_interval] = interval
    end

    def working_directory(path)
      @options[:runpath] = path
    end

    def pid(pidfile)
      @options[:pidfile] = pidfile
    end

    def stderr_path(path)
      @options[:stderr_path] = path
    end

    def stdout_path(path)
      @options[:stdout_path] = path
    end

    def setup(&block)
      @options[:setup] = block
    end

    def teardown(&block)
      @options[:teardown] = block
    end

    def before_fork(&block)
      @options[:before_fork] = block
    end

    def after_fork(&block)
      @options[:after_fork] = block
    end

    def preload_app(yes_no)
      @options[:preload_app] = yes_no
    end

    def daemonize(yes_no)
      @options[:daemon] = yes_no
    end

    def initialize(path)
      @config_path = path
      @options = {}
    end

    def self.process(config_path)
      loader = Resque::Master.new(config_path)
      loader.run
      loader.options
    end

    def run
      eval(File.read(@config_path), binding)
    end

    def self.setup(options)
      puts "running setup with: #{options.inspect}"

      Resque.setup do |forker|
        puts "calling resque setup: #{options.inspect}"
        if options[:preload_app]
          require File.dirname(__FILE__) + "/../config/environment"
          forker.logger   = Rails.logger
        end

        File.open(options[:pidfile],"wb") {|f| f << Process.pid }
        forker.workload = options[:worker_queues] * options[:worker_processes].to_i
        forker.options.interval = options[:work_interval].to_i if options.key?(:work_interval)
      end

      Resque.teardown do|forker|
        File.unlink(options[:pidfile]) if File.exist?(options[:pidfile])
      end

      Resque.before_first_fork do
        options[:before_first_fork].call if options[:before_first_fork].is_a?(Proc)
      end

      Resque.before_fork do
        options[:before_fork].call if options[:before_fork].is_a?(Proc)
      end

      Resque.after_fork do
        options[:after_fork].call if options[:after_fork].is_a?(Proc)
      end
    end

    def self.daemonize(options)
      $pidfile = options[:pidfile]
      rd, wr = IO.pipe

      stdout = options[:stdout_path] || "/dev/null"
      stderr = options[:stderr_path] || "/dev/null"

      # wait for child process to start running before exiting parent process
      fork do
        rd.close
        Process.setsid
        fork do
          begin
            wr.write "Prepare to fork: #{options.inspect}, stdout: #{stdout.inspect}, stderr: #{stderr.inspect}, stdin: /dev/null"
            Process.setsid
            Dir.chdir(options[:runpath])
            File.umask 0000
            STDIN.reopen "/dev/null"
            STDOUT.reopen stdout, "a"
            STDERR.reopen stderr, "a"

            wr.flush
            wr.close # signal to our parent we're up and running, this lets the parent exit

            Resque.fork! # fork to startup the workers
          rescue => e
            if wr.closed?
              STDERR.puts "#{e.message} #{e.backtrace.join("\n")}"
            else
              wr.write e.message
              wr.write e.backtrace.join("\n")
              wr.write "\n"
              wr.write "ERROR!"
              wr.flush
              wr.close
            end
          end
        end
        wr.close
      end

      wr.close
      output = rd.read
      puts output
      rd.close

    end

    def self.optparse!
      options = {}

      optparse = OptionParser.new do|opts|
       # Set a banner, displayed at the top
       # of the help screen.
       opts.banner = "Usage: optparse1.rb [options] file1 file2 ..."

       opts.on( '-d', '--daemon', 'Run the master process as daemon' ) do
         options[:daemon] = true
       end

       opts.on( '-p', '--pid FILE', 'Write pid file to FILE' ) do|file|
         options[:pidfile] = file
       end

       opts.on( '-r', '--run PATH', 'Where to run the forked daemon' ) do|file|
         options[:runpath] = file
       end

       opts.on( '-e', '--stderr PATH', 'Where to send stderr output' ) do|file|
         options[:stderr_path] = file
       end

       opts.on( '-o', '--stdout PATH', 'Where to send stdout output' ) do|file|
         options[:stdout_path] = file
       end

       opts.on( '-c', '--config PATH', 'Path to a configuration file to load' ) do|file|
         options[:config] = file
       end

       opts.on( '-l', '--logfile FILE', 'Write log to FILE' ) do|file|
         options[:logfile] = file
       end

       # This displays the help screen, all programs are
       # assumed to have this option.
       opts.on( '-h', '--help', 'Display this screen' ) do
         puts opts
         exit
       end
      end

      optparse.parse!
      options
    end

    def self.defaults
      {
        :config => nil,
        :logfile => nil,
        :stderr_path => "/dev/null",
        :stdout_path => "/dev/null",
        :runpath => "/",
        :pidfile => nil,
        :daemon => false
      }
    end

  end
end
