require 'trollop'
require 'method_parser'

# Parses command line and configure #Trollop
class CommandLineParser
  attr_reader :global_opts, :method, :init_method
  TYPES_MAPPINGS = {
    'String'         => :string,
    'Integer'        => :int,
    'Fixnum'         => :int,
    'Float'          => :float,
    'Boolean'        => :boolean,
    'Array(String)'  => :strings,
    'Array(Integer)' => :ints,
    'Array(Fixnum)'  => :ints,
    'Array(Float)'   => :floats,
    'Array(Boolean)' => :booleans
  }.freeze

  # Generate tool help menu.
  # IMPORTANT! Should be executed before ARGV.shift
  def initialize(file_parser)
    @file_parser  = file_parser
    @sub_commands = @file_parser.runnable_methods.map { |m| m.name.to_s }
    @parser       = Trollop::Parser.new
    @parser.banner(FileParser.select_runnable_tags(@file_parser.clazz).map { |t| (t.text + "\n") }.join("\n"))
    @parser.stop_on @sub_commands
  end

  def run(action)
    @init_method = method_parse @file_parser.initialize_method
    @global_opts = Trollop::with_standard_exception_handling(@parser) do
      begin
        @parser.parse ARGV
      rescue Trollop::CommandlineError => e
        raise ConsoleRunnerError, "You must provide one of available actions: #{@sub_commands.join ', '}" unless @sub_commands.include?(ARGV[0])
        raise e
      end
    end
    if @init_method
      given_attrs           = @global_opts.keys.select { |k| k.to_s.include? '_given' }.map { |k| k.to_s.gsub('_given', '').to_sym }
      @init_method.cmd_opts = @global_opts.select { |k, _| given_attrs.include? k }
    end
    raise ConsoleRunnerError, "Cannot run! You haven't specify any method to run." unless action

    ARGV.shift
    @method          = method_parse action
    cmd_opts         = Trollop::with_standard_exception_handling @parser do
      unless @method.param_tags.count.zero?
        raise Trollop::HelpNeeded if ARGV.empty?
      end
      # show help screen
      @parser.parse ARGV
    end
    given_attrs      = cmd_opts.keys.select { |k| k.to_s.include? '_given' }.map { |k| k.to_s.gsub('_given', '').to_sym }
    @method.cmd_opts = cmd_opts.select { |k, _| given_attrs.include? k }
    @method.default_params.each do |k, v|
      @method.cmd_opts[k.to_sym] ||= v
    end

    @method.param_tags.select { |t| t.tag_name == 'param' }.map(&:name).each do |required_param|
      next if @method.options_group? required_param
      unless @method.cmd_opts[required_param.to_sym]
        raise ConsoleRunnerError, "You must specify required parameter: #{required_param}"
      end
    end
  end

  def method_parse(yard_method)
    return nil unless yard_method
    method = MethodParser.new yard_method
    method.param_tags.each do |tag|
      tag_name = tag.name
      tag_text = tag.text
      tag_type = tag.type
      if tag_type == "Hash"
        options = method.option_tags.select { |t| t.name == tag.name }
        if options.count > 0
          options.each do |option|
            option_name = option.pair.name.delete(':')
            option_text = option.pair.text
            option_type = option.pair.type
            @parser.opt(option_name.to_sym, "(Ruby class: #{option_type}) " + option_text.to_s, type: CommandLineParser.parse_type(option_type))
          end
        else
          @parser.opt(tag_name.to_sym, "(Ruby class: #{tag_type}) " + tag_text.to_s, type: CommandLineParser.parse_type(tag_type))
        end
      else
        @parser.opt(tag_name.to_sym, "(Ruby class: #{tag_type}) " + tag_text.to_s, type: CommandLineParser.parse_type(tag_type))
      end
    end
    method
  end

  def self.parse_type(yard_type)
    result = TYPES_MAPPINGS[yard_type]
    raise ConsoleRunnerError, "Unsupported YARD type: #{yard_type}" unless result
    result
  end

end

