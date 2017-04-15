class ConsoleRunnerError < StandardError

  def backtrace
    if CommandLineParser.debug?
      @object
    else
      super
    end
  end

end