require 'base_test_class'

class InstanceActionTest < BaseTestClass

  def test_action_with_params
    assert_runner :single_param_action, '--parameter name', init: true, action: true
  end

  def test_action_with_short_params
    assert_runner :single_param_action, '-p name', init: true, action: true
  end

  def test_action_missed_param
    action_key = :single_param_action
    result     = run_runner action_key, ''
    assert_equal 1, result[:exit_code]
    assert_match 'You must specify required parameter: parameter', result[:err].join
    refute_match init_text, result[:out].join
    refute_match action_text(action_key), result[:out].join
  end

  def test_action_one_of_two_missed
    action_key = :two_params_action
    result     = run_runner action_key, '-a "another name"'
    assert_equal 1, result[:exit_code]
    assert_match 'You must specify required parameter: parameter', result[:err].join
    refute_match init_text, result[:out].join
    refute_match action_text(action_key), result[:out].join
  end

  def test_action_one_missed_but_default
    assert_runner :two_params_action_one_default, '-a "another name"', init: true, action: true
  end

  def test_action_two_params
    assert_runner :two_params_action, '-p name -a "another name"', init: true, action: true
  end

  def test_action_unknown_param
    action_key = :single_param_action
    result     = run_runner action_key, '-p name -u unknown'
    assert_equal 1, result[:exit_code]
    assert_match "unknown argument '-u'", result[:err].join
    refute_match init_text, result[:out].join
    refute_match action_text(action_key), result[:out].join
  end

  def test_action_help_menu_with_param
    action_key = :single_param_action
    result     = run_runner action_key, '-p name -h'
    assert_equal 0, result[:exit_code]
    assert_match ACTION_HELP, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
    refute_match init_text, result[:out].join
    refute_match action_text(action_key), result[:out].join
  end

  def test_action_help_menu
    action_key = :single_param_action
    result     = run_runner action_key, '-h'
    assert_equal 0, result[:exit_code]
    assert_match ACTION_HELP, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
    refute_match init_text, result[:out].join
    refute_match action_text(action_key), result[:out].join
  end

  def test_action_not_runable
    action_key = :action_not_runnable
    result     = run_runner action_key, '-p name'
    assert_equal 1, result[:exit_code]
    assert_match 'Cannot find any @runnable action', result[:err].join
    refute_match init_text, result[:out].join
    refute_match action_text(action_key), result[:out].join
  end

  def test_action_without_params
    assert_runner :no_param_action, '', init: true, action: true
  end

  def test_options_hash_params
    assert_runner :action_with_options, '-p name -f option1 --second-option option2', init: true, action: true
  end

  def test_options_hash_missed_option
    assert_runner :action_with_options, '-p name --second-option option2', init: true, action: true
  end

  def test_options_hash_missed_param
    action_key = :action_with_options
    result     = run_runner action_key, '-f option1 --second-option option2'
    assert_equal 1, result[:exit_code]
    assert_match 'You must specify required parameter: parameter', result[:err].join
    refute_match init_text, result[:out].join
    refute_match action_text(action_key), result[:out].join
  end

  def test_same_name_param_option
    action_key = :same_param_name_action
    result     = run_runner action_key, '-p name --second-option option2'
    assert_equal 1, result[:exit_code]
    assert_match(
      'You have the same name for @param and @option attribute(s): parameter. (ConsoleRunnerError)',
      result[:err].join
    )
    refute_match init_text, result[:out].join
    refute_match action_text(action_key), result[:out].join
  end

  def test_actions_without_init
    assert_runner(
      :action_without_init,
      '',
      runnable_file: 'test/assets/runnable_class_wo_init.rb',
      init:          false, action: true
    )
  end

  def test_params_types
    result = assert_runner(
      :say_hello,
      '-d -n John --second-meet --prefix Mr.',
      init: true
    )
    assert_match 'Hello, Mr. John. Nice to see you again!', result[:out].join
  end

  def test_same_name_of_option_and_param
    skip
  end


end
