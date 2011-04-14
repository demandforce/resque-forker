require 'test_helper'

class CLITest < Test::Unit::TestCase

  def test_optparser
    options = Resque::Master.optparse!
    assert_equal({}, options)
    ARGV << "-d"
    ARGV << "-p"
    ARGV << "#{File.dirname(__FILE__)}/test.pid"
    options = Resque::Master.optparse!
    assert_equal true, options[:daemon]
    assert_equal "test/test.pid", options[:pidfile]
  end

  def test_config_file
    config_path = "#{File.dirname(__FILE__)}/sample_config.rb"
    base_path = "/var/www/apps/appname/shared/"
    options = {:config => config_path}
    options = Resque::Master.process(options[:config]).merge(options)
    assert_equal config_path, options[:config]
    assert_equal base_path + "log/workers.log", options[:logfile]
    assert_equal base_path + "log/workers.stderr.log", options[:stderr_path]
    assert_equal base_path + "log/workers.stdout.log", options[:stdout_path]
    assert_equal base_path + "pids/workers.pid", options[:pidfile]
    assert_equal "/var/www/apps/appname/current/", options[:runpath]
    assert_equal true, options[:daemon]
    assert_equal true, options[:preload_app]
    assert_equal ["*"], options[:worker_queues]
    assert_equal 2, options[:worker_processes]
    assert_equal 3, options[:work_interval]
    assert_equal 60, options[:worker_timeout]
    assert options[:setup].is_a?(Proc)
    assert options[:before_fork].is_a?(Proc)
    assert options[:after_fork].is_a?(Proc)
  end

  def test_defaults
    options = Resque::Master.defaults
    assert_equal nil, options[:config]
    assert_equal nil, options[:logfile]
    assert_equal "/dev/null", options[:stderr_path]
    assert_equal "/dev/null", options[:stdout_path]
    assert_equal nil, options[:pidfile]
    assert_equal false, options[:daemon]
    assert_equal true, options[:preload_app]
    assert_equal ["*"], options[:worker_queues]
    assert_equal 1, options[:worker_processes]
    assert_equal 5, options[:work_interval]

  end

  def test_setup_with_options
    config_path = "#{File.dirname(__FILE__)}/sample_test_config.rb"
    base_path = File.expand_path(File.dirname(__FILE__))
    options = {:config => config_path}
    options = Resque::Master.process(options[:config]).merge(options)
    options = Resque::Master.defaults.merge(options)

    Resque::Master.setup(options)

    # verify that setup assigned Proc's to before and after handlers
    assert_nil Resque.before_first_fork
    assert Resque.before_fork.is_a?(Proc)
    assert Resque.after_fork.is_a?(Proc)

  end

end
