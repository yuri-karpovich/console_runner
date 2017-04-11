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

end