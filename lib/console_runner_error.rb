class ConsoleRunnerError < StandardError

  def backtrace(debug = CommandLineParser.debug?)
    if debug
      super
    else
      @object
    end
  end

end