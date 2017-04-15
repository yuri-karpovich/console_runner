class ConsoleRunnerError < StandardError

  def backtrace
    return @object unless CommandLineParser.debug?
    super
  end

end