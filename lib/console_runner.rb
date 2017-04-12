require 'file_parser'
require 'trollop_configurator'
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
  trol_config = TrollopConfigurator.new(file_parser)
  raise ConsoleRunnerError, "Cannot run! You haven't specify any method to run." unless action
  trol_config.parse_method action


  puts '======================================================='
  puts 'Global options:'
  puts trol_config.global_opts.map { |k, v| "     #{k} = #{v}" }.join("\n")
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
        # TODO catch errors
        obj         = klass_obj.new(*init_params)
        obj.send(action.name, *method_params)
      else
        raise ConsoleRunnerError, "Unknown method type: #{method_type}"
    end

  }


# raise ConsoleRunnerError, "#{clazz.name}#initialize method should be specified" unless initialize_method
#
# raise ConsoleRunnerError, "At least one method should be marked with @#{FileParser::RUNNABLE_TAG.to_s} tag.
# Also you may specify #run method and it will be executed by default.
# #run method don't need any code annotations as well." if runnable_methods.count == 0 unless run_method

end