require 'trollop'
require 'method_parser'

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
    @banner            = generate_banner
    @parser.stop_on @sub_commands
    @init_method = nil
  end

  def generate_banner
    result = FileParser.select_runnable_tags(@file_parser.clazz).map(&:text).join("\n")
    result += "\n\n\tAvailable actions:\n"
    result += @sub_commands_text.map do |c, text|
      t = "\t\t- #{c}"
      t += "\n\t\t\t#{text}" if text != ''
      t
    end.join("\n")
    @parser.banner(result)
    result
  end

  def raise_help
    if %w(-h --help).include?(ARGV[0].to_s.strip)
      Trollop::with_standard_exception_handling(@parser) { raise Trollop::HelpNeeded }
    end
    return if @sub_commands.include?(ARGV[0].to_s.strip)
    raise ConsoleRunnerError, "You must provide one of available actions: #{@sub_commands.join ', '}"
  end

  def run(action)
    raise_help
    @init_method ||= MethodParser.new(@file_parser.initialize_method) if @file_parser.initialize_method
    @method      = MethodParser.new action
    [@init_method, @method].each do |method|
      next unless method
      method.trollop_opts.each { |a| @parser.opt(*a) }
      cmd_opts        = Trollop::with_standard_exception_handling @parser do
        unless method.parameters.count.zero?
          raise Trollop::HelpNeeded if ARGV.empty?
        end
        @parser.parse ARGV
      end
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

