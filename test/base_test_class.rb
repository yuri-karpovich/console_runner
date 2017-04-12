require 'test_helper'
require 'colorize'
require 'open3'
require 'assets/exit_codes'

class BaseTestClass < Minitest::Test
  include ExitCodes

  DEBUG             = ENV['DEBUG'].to_s == 'true'
  EXPECTED_CODES    = EXIT_CODES
  RUNNABLE_FILE     = 'test/assets/runnable_class.rb'.freeze
  RUN_COMMAND       = 'ruby exe/c_run'.freeze
  HELP_MENU_TEXT    = '-h, --help'.freeze
  TRY_FOR_HELP_TEXT = 'Try --help for help.'.freeze
  WRONG_ACTION_TEXT = 'You must provide one of available actions: '.freeze

  private

  def assert_code(action_key, params_string, runnable_file = RUNNABLE_FILE)
    params = [action_key, params_string]
    params << runnable_file if runnable_file
    result = run_runner(*params)
    assert_equal EXPECTED_CODES[action_key], result[:exit_code]
    result
  end

  def run_runner(action_key, params_string, runnable_file = RUNNABLE_FILE)
    if DEBUG
      puts "FILE: #{runnable_file}"
      puts "ACTION: #{action_key} with #{params_string}"
      puts "PARAMS: #{params_string}"
    end
    result = { out: [], err: [], exit_code: nil }
    Open3.popen3(
      "#{RUN_COMMAND} #{runnable_file} #{action_key} #{params_string}"
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