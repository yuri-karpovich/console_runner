require 'base_test_class'

class ClassActionTest < BaseTestClass

  def test_class_action_with_params
    assert_code :class_single_param_action, '--parameter name'
  end

  def test_class_action_with_short_params
    assert_code :class_single_param_action, '-p name'
  end

  def test_class_action_missed_param
    result = run_runner :class_single_param_action, ''
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
  end

  def test_class_action_one_of_two_missed
    result = run_runner :class_two_params_action, '-a "another name"'
    assert_equal 1, result[:exit_code]
    assert_match 'You must specify required parameter: parameter', result[:err].join
  end

  def test_class_action_one_missed_but_default
    assert_code :class_two_params_action_one_default, '-a "another name"'
  end

  def test_class_action_two_params
    assert_code :class_two_params_action, '-p name -a "another name"'
  end

  def test_class_action_unknown_param
    result = run_runner :class_single_param_action, '-p name -u unknown'
    assert_equal 255, result[:exit_code]
    assert_match TRY_FOR_HELP_TEXT, result[:err].join
    assert_match "unknown argument '-u'", result[:err].join
  end

  def test_class_action_help_menu_with_param
    result = run_runner :class_single_param_action, '-p name -h'
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
  end

  def test_class_action_help_menu
    result = run_runner :class_single_param_action, '-h'
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    assert_match '--parameter=<s>', result[:out].join
  end

  def test_class_action_not_runable
    result = run_runner :class_action_not_runnable, '-p name'
    assert_equal 1, result[:exit_code]
    assert_match WRONG_ACTION_TEXT, result[:err].join
  end

  def test_class_action_without_params
    assert_code :class_no_param_action, ''
  end

  def test_options_hash_params
    assert_code :class_action_with_options, '-p name -f option1 --second-option option2'
  end

  def test_options_hash_missed_option
    assert_code :class_action_with_options, '-p name --second-option option2'
  end

  def test_options_hash_missed_param
    result = run_runner :class_action_with_options, '-f option1 --second-option option2'
    assert_equal 1, result[:exit_code]
    assert_match 'You must specify required parameter: parameter', result[:err].join
  end

  def test_same_name_param_option
    result = run_runner :class_same_param_name_action, '-p name --second-option option2'
    assert_equal 1, result[:exit_code]
    assert_match(
      'You have the same name for @param and @option attribute(s): parameter. (ConsoleRunnerError)',
      result[:err].join
    )
  end

end
