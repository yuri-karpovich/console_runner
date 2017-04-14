require 'base_test_class'

class ClassActionTest < BaseTestClass

  def test_class_action_with_params
    assert_runner :class_single_param_action, '--parameter name', class_action: true
  end

  def test_class_action_with_short_params
    assert_runner :class_single_param_action, '-p name', class_action: true
  end

  def test_class_action_missed_param
    action_key = :class_single_param_action
    result     = run_runner action_key, ''
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
    refute_match class_action_text(action_key), result[:out].join
  end

  def test_class_action_one_of_two_missed
    action_key = :class_two_params_action
    result     = run_runner action_key, '-a "another name"'
    assert_equal 1, result[:exit_code]
    assert_match 'You must specify required parameter: parameter', result[:err].join
    refute_match class_action_text(action_key), result[:out].join
  end

  def test_class_action_one_missed_but_default
    assert_runner(
      :class_two_params_action_one_default,
      '-a "another name"',
      class_action: true
    )
  end

  def test_class_action_two_params
    assert_runner :class_two_params_action, '-p name -a "another name"', class_action: true
  end

  def test_class_action_unknown_param
    action_key = :class_single_param_action
    result     = run_runner action_key, '-p name -u unknown'
    assert_equal 255, result[:exit_code]
    assert_match TRY_FOR_HELP_TEXT, result[:err].join
    assert_match "unknown argument '-u'", result[:err].join
    refute_match class_action_text(action_key), result[:out].join
  end

  def test_class_action_help_menu_with_param
    action_key = :class_single_param_action
    result     = run_runner action_key, '-p name -h'
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
    refute_match class_action_text(action_key), result[:out].join
  end

  def test_class_action_help_menu
    action_key = :class_single_param_action
    result     = run_runner action_key, '-h'
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
    refute_match class_action_text(action_key), result[:out].join
  end

  def test_class_action_not_runable
    action_key = :class_action_not_runnable
    result     = run_runner action_key, '-p name'
    assert_equal 1, result[:exit_code]
    assert_match WRONG_ACTION_TEXT, result[:err].join
    refute_match class_action_text(action_key), result[:out].join
  end

  def test_class_action_without_params
    assert_runner :class_no_param_action, '', class_action: true
  end

  def test_options_hash_params
    assert_runner :class_action_with_options, '-p name -f option1 --second-option option2', class_action: true
  end

  def test_options_hash_missed_option
    assert_runner :class_action_with_options, '-p name --second-option option2', class_action: true
  end

  def test_options_hash_missed_param
    action_key = :class_action_with_options
    result     = run_runner action_key, '-f option1 --second-option option2'
    assert_equal 1, result[:exit_code]
    assert_match 'You must specify required parameter: parameter', result[:err].join
    refute_match class_action_text(action_key), result[:out].join
  end

  def test_same_name_param_option
    action_key = :class_same_param_name_action
    result     = run_runner action_key, '-p name --second-option option2'
    assert_equal 1, result[:exit_code]
    assert_match(
      'You have the same name for @param and @option attribute(s): parameter. (ConsoleRunnerError)',
      result[:err].join
    )
    refute_match class_action_text(action_key), result[:out].join
  end

end
