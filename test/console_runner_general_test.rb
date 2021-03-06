require 'base_test_class'

class ConsoleRunnerTest < BaseTestClass

  def test_that_it_has_a_version_number
    refute_nil ::ConsoleRunner::VERSION
  end

  def test_no_any_params
    result = run_runner '', ''
    assert_equal 1, result[:exit_code]
    assert_match 'Cannot find any @runnable action', result[:err].join
    refute_match class_action_text(''), result[:out].join
    refute_match action_text(''), result[:out].join
    refute_match init_text, result[:out].join
  end

  def test_tool_help_menu
    result = run_runner '-h', ''
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
    refute_match class_action_text(''), result[:out].join
    refute_match action_text(''), result[:out].join
    refute_match init_text, result[:out].join
  end

  def test_unknown_action
    result = run_runner 'unknown', '-p name'
    assert_equal 1, result[:exit_code]
    assert_match 'Cannot find any @runnable action', result[:err].join
    refute_match class_action_text(''), result[:out].join
    refute_match action_text(''), result[:out].join
    refute_match init_text, result[:out].join
  end

  def test_some_runnable_classes_in_file
    result = run_runner(
      :no_param_action,
      '',
      runnable_file: 'test/assets/some_runnable_classes.rb'
    )
    assert_equal 1, result[:exit_code]
    assert_match(
      'At least one runnable Class should be specified in file (ConsoleRunnerError)',
      result[:err].join
    )
    refute_match class_action_text(''), result[:out].join
    refute_match action_text(''), result[:out].join
    refute_match init_text, result[:out].join
  end

  def test_actions_with_same_names
    result = run_runner :same_name_action, ''
    assert_equal 1, result[:exit_code]
    assert_match(
      'Class and Instance methods have the same name',
      result[:err].join
    )
    refute_match class_action_text(''), result[:out].join
    refute_match action_text(''), result[:out].join
    refute_match init_text, result[:out].join
  end

  def test_debug_param
    action = :single_param_action
    result = run_runner "-d #{action}", '-p name'
    assert_equal EXIT_CODES[action], result[:exit_code]
    refute_match class_action_text(action), result[:out].join
    assert_match action_text(action), result[:out].join
    assert_match init_text, result[:out].join
    assert_match 'debug = true', result[:err].join
    assert_match "Executing ##{action} method...", result[:err].join
  end

  def test_cr_error_debug
    result = run_runner :same_name_action, '-d'
    assert_equal 1, result[:exit_code]
    assert_match(
      'Class and Instance methods have the same name',
      result[:err].join
    )
    assert_match ":in `<main>'", result[:err].join
    refute_match class_action_text(''), result[:out].join
    refute_match action_text(''), result[:out].join
    refute_match init_text, result[:out].join
  end

  def test_run_method
    skip
  end

  def test_initialize_params
    skip
  end

  def test_same_params_in_action_and_init
    skip
  end

  def test_only_init_method_presented
    skip
  end
end
