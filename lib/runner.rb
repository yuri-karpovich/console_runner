module Runner

  def self.run &block
    start_time = Time.now
    puts "Start Time: #{start_time}"
    Thread.current[:id] = 'main'

    yield

    trap 'SIGCHLD' do
      loop do
        pid = Process.waitpid(-1, Process::WNOHANG) rescue nil
        break unless pid
      end
    end

    finish_time = Time.now
    puts "Finish Time: #{finish_time} (Duration: #{((finish_time - start_time) / 60).round(2) } minutes)"
  end

end