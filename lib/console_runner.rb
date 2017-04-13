require 'file_parser'
require 'command_line_parser'
require 'runner'
require 'console_runner/version'

# console_runner logic is here
module ConsoleRunner
  file_from_arg = ARGV.shift
  raise ConsoleRunnerError, 'Specify file to be executed' unless file_from_arg
  file_path   = File.realpath file_from_arg
  file_parser = FileParser.new(file_path)
  cmd         = ARGV[0]
  actions     = file_parser.runnable_methods.select { |m| m.name.to_s == cmd }
  if actions.count > 1
    raise(
      ConsoleRunnerError,
      "Class and Instance methods have the same name (#{cmd}). Actions names should be unique"
    )
  end
  action      = actions.first
  action      ||= file_parser.run_method
  trol_config = CommandLineParser.new(file_parser)
  trol_config.run(action)


  puts '======================================================='
  puts 'Global options:'
  if file_parser.initialize_method
    puts "INIT: #{file_parser.initialize_method.name}"
    puts 'INIT options:'
    puts trol_config.init_method.cmd_opts.map { |k, v| "     #{k} = #{v}" }.join("\n")
  end
  puts "Subcommand: #{action.name}"
  puts 'Subcommand options:'
  puts trol_config.method.cmd_opts.map { |k, v| "     #{k} = #{v}" }.join("\n")
  puts "Remaining arguments: #{ARGV.inspect}" if ARGV != []
  puts '======================================================='


  Runner.run {
    require file_path
    class_full_name = file_parser.clazz.title
    raise ConsoleRunnerError, "#{class_full_name} is not defined" unless Module.const_defined?(class_full_name)
    klass_obj     = Module.const_get(class_full_name)
    method_type   = action.scope
    method_params = trol_config.method.params_array

    case method_type
      when :class
        klass_obj.send(action.name, *method_params)
      when :instance
        init_method = trol_config.init_method
        init_params = []
        init_params = init_method.params_array if init_method
        obj         = klass_obj.new(*init_params)
        obj.send(action.name, *method_params)
      else
        raise ConsoleRunnerError, "Unknown method type: #{method_type}"
    end

  }

end