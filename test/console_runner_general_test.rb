require 'base_test_class'

class ConsoleRunnerTest < BaseTestClass

  def test_that_it_has_a_version_number
    refute_nil ::ConsoleRunner::VERSION
  end

  def test_tool_help_menu
    result = run_runner '-h', ''
    assert_equal 0, result[:exit_code]
    assert_match HELP_MENU_TEXT, result[:out].join
  end

  def test_unknown_action
    result = run_runner 'unknown', '-p name'
    assert_equal 1, result[:exit_code]
    assert_match WRONG_ACTION_TEXT, result[:err].join
  end

  def test_some_runnable_classes_in_file
    result = run_runner :no_param_action, '', 'test/assets/some_runnable_classes.rb'
    assert_equal 1, result[:exit_code]
    assert_match(
      'One runnable Class should be specified in file. (ConsoleRunnerError)',
      result[:err].join
    )
  end

  def test_actions_without_init
    assert_code :action_without_init, '', 'test/assets/runnable_class_wo_init.rb'
  end

end
