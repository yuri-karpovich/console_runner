require 'trollop'
require 'method_parser'
require 'colorize'

# Parses command line and configure #Trollop
class CommandLineParser
  attr_reader :method, :init_method

  # Generate tool help menu.
  # IMPORTANT! Should be executed before ARGV.shift
  def initialize(file_parser)
    @file_parser       = file_parser
    @sub_commands      = @file_parser.runnable_methods.map { |m| m.name.to_s }
    @sub_commands_text = @file_parser.runnable_methods.map do |m|
      [
        m.name.to_s,
        FileParser.select_runnable_tags(m).map(&:text).join("\n")
      ]
    end.to_h
    @parser            = Trollop::Parser.new
    @parser.stop_on @sub_commands
    @init_method = nil
  end

  def tool_banner
    result = FileParser.select_runnable_tags(@file_parser.clazz).map(&:text).join("\n")
    result += "\n\n\tAvailable actions:\n"
    result += @sub_commands_text.map do |c, text|
      t = "\t\t- #{c}"
      t += "\n\t\t\t#{text}" if text != ''
      t
    end.join("\n")
    result
  end

  def maybe_help(banner, action_name = nil)
    action = action_name
    scope = ARGV
    if action_name
      action_index = ARGV.index(action)
      scope = ARGV[0..action_index] if action_index
    end
    return unless scope.any?{|a| %w(-h --help).include? a }
    @parser.banner(banner)
    Trollop::with_standard_exception_handling(@parser) { raise Trollop::HelpNeeded }
  end

  def raise_on_action_absence(sub_commands)
    return if ARGV.any? {|a| sub_commands.include? a }
    raise ConsoleRunnerError, "You must provide one of available actions: #{sub_commands.join ', '}"
  end

  def run(action)
    maybe_help(tool_banner, action ? action.name.to_s : nil )
    raise ConsoleRunnerError, 'Cannot find any @runnable action' unless action
    raise_on_action_absence @sub_commands
    @init_method ||= MethodParser.new(@file_parser.initialize_method) if @file_parser.initialize_method
    @method      = MethodParser.new action
    [@init_method, @method].each do |method|
      next unless method
      method.trollop_opts.each { |a| @parser.opt(*a) }
      maybe_help(method.text, action.name.to_s)
      cmd_opts        = @parser.parse ARGV
      given_attrs     = cmd_opts.keys.select { |k| k.to_s.include? '_given' }.map { |k| k.to_s.gsub('_given', '').to_sym }
      method.cmd_opts = cmd_opts.select { |k, _| given_attrs.include? k }
      method.default_values.each do |k, v|
        method.cmd_opts[k.to_sym] ||= v
      end
      method.required_parameters.each do |required_param|
        next if method.options_group? required_param
        next if method.cmd_opts[required_param.to_sym]
        raise ConsoleRunnerError, "You must specify required parameter: #{required_param}"
      end
      ARGV.shift
    end
  end

end

