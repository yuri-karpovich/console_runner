class ConsoleRunnerError < StandardError

  def backtrace
    if ENV['CR_DEBUG'].to_s == 'true'
      super
    else
      @object
    end
  end
  
end