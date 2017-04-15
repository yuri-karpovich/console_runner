# Parses method code
class MethodParser
  attr_reader :method,
              :name,
              :text,
              :parameters,
              :param_tags, # All method parameters tags
              :option_tags, # Only options tags
              :trollop_opts,
              :default_values,
              :required_parameters

  attr_accessor :cmd_opts

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

  # @param [YARD::CodeObjects::MethodObject] method YARD method object to be parsed
  def initialize(method)
    @method              = method
    @name                = @method.name
    @text                = FileParser.select_runnable_tags(@method).map(&:text).join("\n")
    @parameters          = @method.parameters
    @default_values      = default_params
    @param_tags          = FileParser.select_param_tags @method
    @option_tags         = FileParser.select_option_tags @method
    @required_parameters = @param_tags.select { |t| t.tag_name == 'param' }.map(&:name)
    @cmd_opts            = nil
    same_params          = param_tags_names & option_tags_names
    unless same_params.count.zero?
      raise(
        ConsoleRunnerError,
        "You have the same name for @param and @option attribute(s): #{same_params.join(', ')}.
Use different names to `console_runner` be able to run #{@name} method."
      )
    end
    @trollop_opts = prepare_opts_for_trollop
  end

  def prepare_opts_for_trollop
    result = []
    param_tags.each do |tag|
      tag_name = tag.name
      tag_text = tag.text
      tag_type = tag.type
      if tag_type == "Hash"
        options = option_tags.select { |t| t.name == tag.name }
        if options.count > 0
          options.each do |option|
            option_name = option.pair.name.delete(':')
            option_text = option.pair.text
            option_type = option.pair.type
            result << [
              option_name.to_sym,
              "(Ruby class: #{option_type}) " + option_text.to_s,
              type: parse_type(option_type)
            ]
          end
        else
          result << [
            tag_name.to_sym,
            "(Ruby class: #{tag_type}) " + tag_text.to_s,
            type: parse_type(tag_type)
          ]
        end
      else
        result << [
          tag_name.to_sym,
          "(Ruby class: #{tag_type}) " + tag_text.to_s,
          type: parse_type(tag_type)
        ]
      end
    end
    result
  end

  def params_array
    options_groups = {}
    get_params     = {}
    @parameters.map(&:first).map.with_index { |p, i| [i, p] }.to_h.each do |index, name|
      if options_group?(name)
        options_groups[index] = name
        get_params[index]     = option_as_hash(name)
      else
        get_params[index] = @cmd_opts[name.to_sym]
      end
    end
    get_params  = get_params.to_a.sort_by { |a| a[0] }.reverse
    stop_delete = false
    get_params.delete_if do |a|
      index       = a[0]
      value       = a[1]
      result      = value.nil?
      result      = value == {} if options_groups[index]
      stop_delete = true unless result
      next if stop_delete
    end
    get_params.sort_by { |a| a[0] }.map { |a| a[1] }
  end


  # @return [Array(String)] Names of parameters
  def param_tags_names
    param_tags.map(&:name)
  end

  # @return [Array(String)] Names of options
  def option_tags_names
    option_tags.map { |t| t.pair.name.delete(':') }
  end

  # Check if the name is an option
  #
  # @param [String] param_name name of parameter to be verified
  # @return [Boolean] true if current parameter name is an option key
  def options_group?(param_name)
    option_tags.any? { |t| t.name == param_name }
  end


  private

  def parse_type(yard_type)
    result = TYPES_MAPPINGS[yard_type]
    raise ConsoleRunnerError, "Unsupported YARD type: #{yard_type}" unless result
    result
  end

  # @return [Hash] default values for parameters
  def default_params
    @parameters.to_a.map do |array|
      array.map do |a|
        if a
          ['"', "'"].include?(a[0]) && ['"', "'"].include?(a[-1]) ? a[1..-2] : a
        else
          a
        end
      end
    end.to_h
  end

  # @return [Hash] options parameter as Hash
  def option_as_hash(options_group_name)
    result = {}
    option_tags.select { |t| t.name == options_group_name }.each do |t|
      option_name         = t.pair.name.delete(':')
      option_value        = @cmd_opts[option_name.to_sym]
      result[option_name] = option_value if option_value
    end
    result
  end
end