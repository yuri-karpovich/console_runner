require 'optimist'
require 'method_parser'
require 'colorize'

# Parses command line and configure #Optimist
class CommandLineParser
  attr_reader :method, :initialize_method, :file_parser
  @debug = false

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
    @parser            = Optimist::Parser.new
    @parser.opt(:debug, 'Run in debug mode.', type: :flag)
    @parser.stop_on @sub_commands
    @initialize_method = nil
  end

  def self.debug?
    @debug
  end

  def self.debug=(value)
    return if @debug
    ENV['CR_DEBUG'] = 'true'
    @debug          = value
  end

  def tool_banner
    result = FileParser.select_runnable_tags(@file_parser.clazz).map(&:text).join("\n")
    result += "\n\nAvailable actions:\n"
    result += @sub_commands_text.map do |c, text|
      t = "\t- #{c}"
      t += "\n\t\t#{text}" if text != ''
      t
    end.join("\n")
    result
  end

  def maybe_help(banner, action_name = nil)
    action = action_name
    scope  = ARGV
    if action_name
      action_index = ARGV.index(action)
      scope        = ARGV[0..action_index] if action_index
    end
    return unless scope.any? { |a| %w(-h --help).include? a }
    @parser.banner("\n" + banner)
    Optimist::with_standard_exception_handling(@parser) { raise Optimist::HelpNeeded }
  end

  def raise_on_action_absence(sub_commands)
    return if ARGV.any? { |a| sub_commands.include? a }
    raise ConsoleRunnerError, "You must provide one of available actions: #{sub_commands.join ', '}"
  end

  def run(action)
    maybe_help(tool_banner, action ? action.name.to_s : nil)
    raise ConsoleRunnerError, 'Cannot find any @runnable action' unless action
    raise_on_action_absence @sub_commands
    @initialize_method ||= MethodParser.new(@file_parser.initialize_method) if @file_parser.initialize_method
    @method            = MethodParser.new action
    [@initialize_method, @method].each do |method|
      next unless method
      method.optimist_opts.each { |a| @parser.opt(*a) }
      maybe_help(method.text, action.name.to_s)


      # Read code defaults
      # def droplet_create(name, region = 1, image = nil, size = nil, ssh_keys = nil)
      argv_from_code_defaults = []
      method.default_values.each do |k, param_value_from_code|
        param_name_from_code = k.to_sym
        next if method.option_tags.map(&:name).include?(param_name_from_code.to_s)
        next if param_value_from_code == 'nil'

        argv_from_code_defaults << "--#{param_name_from_code.to_s.gsub('_', '-')}"
        argv_from_code_defaults << param_value_from_code
      end
      # Raise on constant found
      constants = file_parser.constants
      argv_from_code_defaults.map do |x|
        existing_constant = constants.find { |c| c.name.to_s == x }
        raise "Constants as default params values are not supported by console_runner: #{existing_constant.name}" if existing_constant
      end
      parsed_code_default_args     = @parser.parse(argv_from_code_defaults)
      params_names_from_code       = parsed_code_default_args.keys.select { |k| k.to_s.include? '_given' }.map { |k| k.to_s.gsub('_given', '').to_sym }
      params_with_values_from_code = parsed_code_default_args.select { |k, _| params_names_from_code.include? k }
      params_with_values_from_code.delete_if { |k, v| v == 'nil' }


      parsed_cli_args            = @parser.parse ARGV
      params_names_from_cl       = parsed_cli_args.keys.select { |k| k.to_s.include? '_given' }.map { |k| k.to_s.gsub('_given', '').to_sym }
      params_with_values_from_cl = parsed_cli_args.select { |k, _| params_names_from_cl.include? k }


      method.cmd_opts = params_with_values_from_code.merge(params_with_values_from_cl)
      missed_params   = []
      method.required_parameters.each do |required_param|
        next if method.options_group? required_param
        next if method.cmd_opts[required_param.to_sym]
        missed_params << required_param
      end
      raise ConsoleRunnerError, "You must specify required parameter: #{missed_params.join(', ')}" if missed_params.count.positive?
      ARGV.shift
    end
  end

end