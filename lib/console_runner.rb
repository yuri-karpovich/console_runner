require 'file_parser'
require 'cmd_parser'
require 'runner'
require 'console_runner/version'


module ConsoleRunner
  file_from_arg = ARGV.shift
  raise ConsoleRunnerError, 'Specify file to be executed' unless file_from_arg
  file_path   = File.realpath file_from_arg
  file_parser = FileParser.new(file_path)


  runnable_classes = file_parser.list_classes(:runnable)
  if runnable_classes.count != 1
    raise ConsoleRunnerError, "One runnable Class should be specified in file.
Runnable class should be marked with @#{FileParser::RUNNABLE_TAG} tag"
  end

  clazz             = runnable_classes.first
  all_methods       = file_parser.list_methods(:all, clazz)
  runnable_methods  = file_parser.list_methods(:runnable, clazz)
  initialize_method = all_methods.find { |m| m.name == :initialize }
  run_method        = all_methods.find { |m| m.name == :run }


  cmd           = ARGV[0]
  action_method = runnable_methods.find { |m| m.name.to_s == cmd } # get sub-command
  action_method ||= run_method
  cmd_parser    = CmdParser.new(runnable_methods, initialize_method)
  raise ConsoleRunnerError, "Cannot run! You haven't specify any method to run." unless action_method
  cmd_parser.parse_method action_method


  puts '======================================================='
  puts 'Global options:'
  puts cmd_parser.global_opts.map { |k, v| "     #{k} = #{v}" }.join("\n")
  if initialize_method
    puts "INIT: #{initialize_method.name}"
    puts 'INIT options:'
    puts cmd_parser.init_method.cmd_opts.map { |k, v| "     #{k} = #{v}" }.join("\n")
  end
  puts "Subcommand: #{action_method.name}"
  puts 'Subcommand options:'
  puts cmd_parser.method.cmd_opts.map { |k, v| "     #{k} = #{v}" }.join("\n")
  puts "Remaining arguments: #{ARGV.inspect}" if ARGV != []
  puts '======================================================='


  Runner.run {
    require file_path
    class_full_name = clazz.title
    raise ConsoleRunnerError, "#{class_full_name} is not defined" unless Module.const_defined?(class_full_name)
    klass_obj     = Module.const_get(class_full_name)
    method_type   = action_method.scope
    method_params = cmd_parser.method.params_array

    case method_type
      when :class
        klass_obj.send(action_method.name, *method_params)
      when :instance
        init_method = cmd_parser.init_method
        init_params = []
        init_params = init_method.params_array if init_method
        # TODO catch errors
        obj         = klass_obj.new(*init_params)
        obj.send(action_method.name, *method_params)
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