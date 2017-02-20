require 'test_helper'
require 'colorize'

class ConsoleRunnerTest < Minitest::Test

  RUN_COMMAND = 'ruby exe/c_run.rb'


  def test_that_it_has_a_version_number
    refute_nil ::ConsoleRunner::VERSION
  end

  def test_that_it_can_start
    out = []
    err = []
    exit_code = nil
    require 'open3'

    Open3.popen3("#{RUN_COMMAND} test/assets/runnable_classes.rb action -s 1") do |stdin, stdout, stderr, wait_thr|
      stdout.each_line { |line|
        out << line
        puts line.green
      }
      stderr.each_line {|line|
        err << line
        puts line.red
      }
      exit_code = wait_thr.value.exitstatus
    end
    exit_code = nil
  end

  def test_that_it_cannot
    out = []
    err = []
    exit_code = nil
    require 'open3'

    Open3.popen3("ruby exe/c_run.rb test/assets/runnable_classes.rb") do |stdin, stdout, stderr, wait_thr|
      stdout.each_line { |line|
        out << line
        puts line.green
      }
      stderr.each_line {|line|
        err << line
        puts line.red
      }
      exit_code = wait_thr.value.exitstatus
    end
    exit_code = nil
  end
end
