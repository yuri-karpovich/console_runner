require 'test_helper'
require 'colorize'
require 'open3'
require 'assets/runnable_class'

class BaseTestClass < Minitest::Test
  DEBUG             = ENV['DEBUG'].to_s == 'true'
  EXPECTED_CODES    = RunnableClass::EXIT_CODES
  RUNNABLE_FILE     = 'test/assets/runnable_class.rb'.freeze
  RUN_COMMAND       = 'ruby exe/c_run'.freeze
  HELP_MENU_TEXT    = '-h, --help'.freeze
  TRY_FOR_HELP_TEXT = 'Try --help for help.'.freeze
  WRONG_ACTION_TEXT = 'You must provide one of available actions: '.freeze

  private

  def assert_code(action_key, params_string)
    result = run_runner action_key, params_string
    assert_equal EXPECTED_CODES[action_key], result[:exit_code]
    result
  end

  def run_runner(action_key, params_string)
    puts "STARTING #{action_key} with #{params_string}" if DEBUG
    result = { out: [], err: [], exit_code: nil }
    Open3.popen3(
      "#{RUN_COMMAND} #{RUNNABLE_FILE} #{action_key} #{params_string}"
    ) do |stdin, stdout, stderr, wait_thr|
      stdout.each_line do |line|
        result[:out] << line
        puts line.green if DEBUG
      end
      stderr.each_line do |line|
        result[:err] << line
        puts line.red if DEBUG
      end
      result[:exit_code] = wait_thr.value.exitstatus
      puts "EXIT CODE: #{result[:exit_code]}" if DEBUG
    end
    result
  end


end