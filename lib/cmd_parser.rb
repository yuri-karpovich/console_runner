require 'trollop'

class CmdParser

  class ParsedMethod
    attr_reader :method, :name, :param_tags, :option_tags
    attr_accessor :cmd_opts
    def initialize(method)
      @method = method
      @name = @method.name
      @parameters = @method.parameters
      @param_tags = FileParser.select_param_tags @method
      @option_tags = FileParser.select_option_tags @method
      @cmd_opts = nil
    end

    def params_array
      expected_params = @parameters.map(&:first).map.with_index { |p, i| [i, p] }.to_h
      options_groups = {}
      get_params = {}

      expected_params.each do |index, name|
        if is_options_group?(name)
          options_groups[index] = name
          get_params[index] = option_as_hash(name)
        else
          get_params[index] = @cmd_opts[name.to_sym]
        end
      end
      get_params = get_params.to_a.sort_by { |a| a[0] }.reverse

      stop_delete = false
      get_params.delete_if do |a|
        index = a[0]
        value = a[1]
        result = false

        if options_groups[index]
          result = value == {}
        else
          result = value == nil
        end
        stop_delete = true unless result
        next if stop_delete
        result
      end

      get_params.sort_by { |a| a[0] }.map { |a| a[1] }
    end


    def param_tags_names
      param_tags.map { |t| t.name }
    end

    def option_tags_names
      option_tags.map { |t| t.pair.name.gsub(':', '') }
    end

    private

    def is_options_group?(param_name)
      option_tags.any? { |t| t.name == param_name }
    end

    def option_as_hash(options_group_name)
      result = {}
      option_tags.select { |t| t.name == options_group_name }.each do |t|
        option_name = t.pair.name.gsub(':', '')
        option_value = @cmd_opts[option_name.to_sym]
        result[option_name] = option_value if option_value
      end
      result
    end
  end

  attr_reader :global_opts, :method, :init_method

  # Should be executed before ARGV.shift
  def initialize(runnable_methods, init_method= nil)
    clazz = runnable_methods.first.parent
    sub_commands = runnable_methods.map { |m| m.name.to_s }
    @parser = Trollop::Parser.new
    @parser.banner(FileParser.select_runnable_tags(clazz).map { |t| (t.text + "\n") }.join("\n"))
    @parser.stop_on sub_commands

    if init_method
      @init_method = ParsedMethod.new init_method
      same_methods = @init_method.param_tags_names & @init_method.option_tags_names
      raise "You have the same name for @param and @option attribute(s): #{same_methods.join(', ')}.
Use different names to `console_runner` be able to run #{@init_method.name} method." if same_methods.count > 0


      @init_method.param_tags.each do |tag|
        tag_name = tag.name
        tag_text = tag.text
        tag_type = tag.type
        if tag_type == "Hash"
          options = option_tags.select { |t| t.name == tag.name }
          if options.count > 0
            options.each do |option|
              option_name = option.pair.name.gsub(':', '')
              option_text = option.pair.text
              option_type = option.pair.type
              @parser.opt(option_name.to_sym, "(Ruby class: #{option_type}) " + option_text.to_s, type: CmdParser.parse_type(option_type))
            end
          else
            @parser.opt(tag_name.to_sym, "(Ruby class: #{tag_type}) " + tag_text.to_s, type: CmdParser.parse_type(tag_type))
          end
        else
          @parser.opt(tag_name.to_sym, "(Ruby class: #{tag_type}) " + tag_text.to_s, type: CmdParser.parse_type(tag_type))
        end
      end
    end

    @global_opts = Trollop::with_standard_exception_handling(@parser) do
      begin
        @parser.parse ARGV
      rescue Trollop::CommandlineError => e
        raise "You must provide one of available actions: #{sub_commands.join ', '}" unless sub_commands.include?(ARGV[0])
        raise e
      end
    end

    if @init_method
      given_attrs = @global_opts.keys.select { |k| k.to_s.include? '_given' }.map { |k| k.to_s.gsub('_given', '').to_sym }
      @init_method.cmd_opts = @global_opts.select { |k, v| given_attrs.include? k }
    end
  end


  def parse_method(method)
    ARGV.shift
    @method = ParsedMethod.new method
    same_methods = @method.param_tags_names & @method.option_tags_names
    raise "You have the same name for @param and @option attribute(s): #{same_methods.join(', ')}.
Use different names to `console_runner` be able to run #{@method.name} method." if same_methods.count > 0


    @method.param_tags.each do |tag|
      tag_name = tag.name
      tag_text = tag.text
      tag_type = tag.type
      if tag_type == "Hash"
        options = @method.option_tags.select { |t| t.name == tag.name }
        if options.count > 0
          options.each do |option|
            option_name = option.pair.name.gsub(':', '')
            option_text = option.pair.text
            option_type = option.pair.type
            @parser.opt(option_name.to_sym, "(Ruby class: #{option_type}) " + option_text.to_s, type: CmdParser.parse_type(option_type))
          end
        else
          @parser.opt(tag_name.to_sym, "(Ruby class: #{tag_type}) " + tag_text.to_s, type: CmdParser.parse_type(tag_type))
        end
      else
        @parser.opt(tag_name.to_sym, "(Ruby class: #{tag_type}) " + tag_text.to_s, type: CmdParser.parse_type(tag_type))
      end
    end
    cmd_opts = Trollop::with_standard_exception_handling @parser do
      raise Trollop::HelpNeeded if ARGV.empty? # show help screen
      @parser.parse ARGV
    end
    given_attrs = cmd_opts.keys.select { |k| k.to_s.include? '_given' }.map { |k| k.to_s.gsub('_given', '').to_sym }

    @method.cmd_opts = cmd_opts.select { |k, v| given_attrs.include? k }
  end

  def self.parse_type(yard_type)
    case yard_type
      when 'String'
        :string
      when 'Integer'
        :int
      when 'Fixnum'
        :int
      when 'Float'
        :float
      when 'Boolean'
        :boolean
      when 'Array(String)'
        :strings
      when 'Array(Integer)'
        :ints
      when 'Array(Fixnum)'
        :ints
      when 'Array(Float)'
        :floats
      when 'Array(Boolean)'
        :booleans
      else
        raise "Unsupported YARD type: #{yard_type}"
    end
  end

end

