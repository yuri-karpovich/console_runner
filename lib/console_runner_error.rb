class ConsoleRunnerError < StandardError

  unless ENV['DEBUG'].to_s == 'true'
    def backtrace
      @object
    end
  end

end