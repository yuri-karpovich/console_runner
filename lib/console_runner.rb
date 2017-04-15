require 'file_parser'
require 'command_line_parser'
require 'console_runner/version'

# console_runner logic is here
module ConsoleRunner
  CommandLineParser.debug = ARGV.any? { |a| %w(-d --debug).include? a }
  SEPARATOR               = '==================================='.freeze
  begin
    start_time     = Time.now
    success_status = true
    puts "#{SEPARATOR}\nStart Time: #{start_time}\n#{SEPARATOR}".blue
    file_from_arg = ARGV.shift
    raise ConsoleRunnerError, 'Specify file to be executed' unless file_from_arg
    file_path      = File.realpath file_from_arg
    file_parser    = FileParser.new(file_path)
    next_arguments = ARGV.dup
    %w(-d --debug -h --help).each { |a| next_arguments.delete a }
    cmd     = next_arguments[0]
    actions = file_parser.runnable_methods.select { |m| m.name.to_s == cmd }
    if actions.count > 1
      raise(
        ConsoleRunnerError,
        "Class and Instance methods have the same name (#{cmd}). Actions names should be unique"
      )
    end
    action        = actions.first
    action        ||= file_parser.run_method
    c_line_parser = CommandLineParser.new(file_parser)
    c_line_parser.run(action)

    debug_message = SEPARATOR
    if c_line_parser.initialize_method
      debug_message += "\ninitialize method execution\n"
      debug_message += c_line_parser.initialize_method.cmd_opts.map { |k, v| "     #{k} = #{v}" }.join("\n")
    end
    debug_message += "\n#{action.name} method execution\n"
    debug_message += c_line_parser.method.cmd_opts.map { |k, v| "     #{k} = #{v}" }.join("\n")
    debug_message += "\nRemaining arguments: #{ARGV.inspect}" if ARGV != []
    debug_message += "\n#{SEPARATOR}"
    puts debug_message if CommandLineParser.debug?

    require file_path
    class_full_name = file_parser.clazz.title
    raise ConsoleRunnerError, "#{class_full_name} is not defined" unless Module.const_defined?(class_full_name)
    klass_obj     = Module.const_get(class_full_name)
    method_type   = action.scope
    method_params = c_line_parser.method.params_array

    case method_type
      when :class
        klass_obj.send(action.name, *method_params)
      when :instance
        init_method = c_line_parser.initialize_method
        init_params = []
        init_params = init_method.params_array if init_method
        obj         = klass_obj.new(*init_params)
        obj.send(action.name, *method_params)
      else
        raise ConsoleRunnerError, "Unknown method type: #{method_type}"
    end
  rescue => e
    success_status = false
    raise e
  ensure
    finish_time = Time.now
    status      = success_status ? 'Success'.green : 'Error'.red
    puts "\n#{SEPARATOR}".blue
    puts 'Execution status: '.blue + status
    puts "Finish Time: #{finish_time} (Duration: #{((finish_time - start_time) / 60).round(2) } minutes)
#{SEPARATOR}\n".blue
  end
end