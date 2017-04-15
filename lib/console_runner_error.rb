class ConsoleRunnerError < StandardError

  def backtrace
    if CommandLineParser.debug?
      super
    else
      @object
    end
  end

end