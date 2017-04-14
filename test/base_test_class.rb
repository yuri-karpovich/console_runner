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
  # HELP_MENU_TEXT    = '-h, --help'.freeze
  HELP_MENU_TEXT    = 'Here you can specify you tool description. This message will be shown in you'.freeze
  TRY_FOR_HELP_TEXT = 'Try --help for help.'.freeze
  WRONG_ACTION_TEXT = 'You must provide one of available actions'.freeze

  private

  def assert_runner(action_key, params_string, options = {})
    runnable_file = options[:runnable_file]
    runnable_file ||= RUNNABLE_FILE
    result        = run_runner(action_key, params_string, runnable_file: runnable_file)
    if options[:init]
      assert_match(init_text, result[:out].join)
    else
      refute_match(init_text, result[:out].join)
    end
    if options[:action]
      assert_match(action_text(action_key), result[:out].join)
    else
      refute_match(action_text(action_key), result[:out].join)
    end
    if options[:class_action]
      assert_match(class_action_text(action_key), result[:out].join)
    else
      refute_match(class_action_text(action_key), result[:out].join)
    end
    assert_equal EXPECTED_CODES[action_key], result[:exit_code]
    result
  end

  def action_text(action_key)
    "IN ACTION METHOD: #{action_key}"
  end

  def class_action_text(action_key)
    "IN CLASS ACTION METHOD: #{action_key}"
  end

  def init_text
    'IN INITIALIZE METHOD'
  end

  def run_runner(action_key, params_string, options = {})
    runnable_file = options[:runnable_file]
    runnable_file ||= RUNNABLE_FILE
    command       = "#{RUN_COMMAND} #{runnable_file} #{action_key} #{params_string}"
    result        = { out: [], err: [], exit_code: nil }
    Open3.popen3(command) do |_stdin, stdout, stderr, wait_thr|
      stdout.each_line do |line|
        result[:out] << line
        puts line.green if DEBUG
      end
      stderr.each_line do |line|
        result[:err] << line
        puts line.red if DEBUG
      end
      result[:exit_code] = wait_thr.value.exitstatus
      if DEBUG
        puts "#{command}
EXIT CODE: #{result[:exit_code]}"
      end
    end
    result
  end

end