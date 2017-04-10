require 'test_helper'
require 'colorize'
require 'open3'
require 'assets/runnable_class'

class ConsoleRunnerTest < Minitest::Test
  EXPECTED_CODES    = RunnableClass::EXIT_CODES
  RUNNABLE_FILE     = 'test/assets/runnable_class.rb'.freeze
  RUN_COMMAND       = 'ruby exe/c_run.rb'.freeze
  HELP_MENU_TEXT    = '-h, --help'.freeze
  TRY_FOR_HELP_TEXT = 'Try --help for help.'.freeze
  WRONG_ACTION_TEXT = 'You must provide one of available actions: '.freeze

  def test_that_it_has_a_version_number
    refute_nil ::ConsoleRunner::VERSION
  end

  def test_action_with_params
    assert_code :single_param_action, '--parameter name'
  end

  def test_action_with_short_params
    assert_code :single_param_action, '-p name'
  end

  def test_action_missed_param
    result = run_runner :single_param_action, ''
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
  end

  def test_action_one_of_two_missed
    result = run_runner :two_params_action, '-a "another name"'
    assert_equal 1, result[:exit_code]
    assert_match 'You must specify required parameter: parameter', result[:err].join
  end

  def test_action_one_missed_but_default
    assert_code :two_params_action_one_default, '-a "another name"'
  end

  def test_action_two_params
    assert_code :two_params_action, '-p name -a "another name"'
  end

  def test_action_unknown_param
    result = run_runner :single_param_action, '-p name -u unknown'
    assert_equal 255, result[:exit_code]
    assert_match TRY_FOR_HELP_TEXT, result[:err].join
    assert_match "unknown argument '-u'", result[:err].join
  end

  def test_action_help_menu_with_param
    result = run_runner :single_param_action, '-p name -h'
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
  end

  def test_action_help_menu
    result = run_runner :single_param_action, '-h'
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
  end

  def test_tool_help_menu
    result = run_runner '-h', ''
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
  end

  def test_action_not_runable
    result = run_runner :action_not_runnable, '-p name'
    assert_equal 1, result[:exit_code]
    assert_match WRONG_ACTION_TEXT, result[:err].join
  end

  def test_unknown_action
    result = run_runner 'unknown', '-p name'
    assert_equal 1, result[:exit_code]
    assert_match WRONG_ACTION_TEXT, result[:err].join
  end

  def test_action_without_params
    assert_code :no_param_action, ''
  end

  def test_options_hash_params
    assert_code :action_with_options, '-p name -f option1 --second-option option2'
  end

  def test_options_hash_missed_option
    assert_code :action_with_options, '-p name --second-option option2'
  end

  def test_options_hash_missed_param
    result = run_runner :action_with_options, '-f option1 --second-option option2'
    assert_equal 1, result[:exit_code]
    assert_match 'You must specify required parameter: parameter', result[:err].join
  end

  private

  def assert_code(action_key, params_string)
    result = run_runner action_key, params_string
    assert_equal EXPECTED_CODES[action_key], result[:exit_code]
    result
  end

  def run_runner(action_key, params_string)
    puts "STARTING #{action_key} with #{params_string}"
    result = { out: [], err: [], exit_code: nil }
    Open3.popen3(
      "#{RUN_COMMAND} #{RUNNABLE_FILE} #{action_key} #{params_string}"
    ) do |stdin, stdout, stderr, wait_thr|
      stdout.each_line do |line|
        result[:out] << line
        puts line.green
      end
      stderr.each_line do |line|
        result[:err] << line
        puts line.red
      end
      result[:exit_code] = wait_thr.value.exitstatus
      puts "EXIT CODE: #{result[:exit_code]}"
    end
    result
  end

end
