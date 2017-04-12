# Parses method code
class MethodParser
  attr_reader :method,
              :name,
              :param_tags, # All method parameters tags
              :option_tags # Only options tags

  attr_accessor :cmd_opts

  # @param [YARD::CodeObjects::MethodObject] method YARD method object to be parsed
  def initialize(method)
    @method      = method
    @name        = @method.name
    @parameters  = @method.parameters
    @param_tags  = FileParser.select_param_tags @method
    @option_tags = FileParser.select_option_tags @method
    @cmd_opts    = nil
    same_params = param_tags_names & option_tags_names
    if same_params.count > 0
      raise(
        ConsoleRunnerError,
        "You have the same name for @param and @option attribute(s): #{same_params.join(', ')}.
Use different names to `console_runner` be able to run #{@name} method."
      )
    end
  end

  # Prepare
  def params_array
    expected_params = @parameters.map(&:first).map.with_index { |p, i| [i, p] }.to_h
    options_groups  = {}
    get_params      = {}

    expected_params.each do |index, name|
      if options_group?(name)
        options_groups[index] = name
        get_params[index]     = option_as_hash(name)
      else
        get_params[index] = @cmd_opts[name.to_sym]
      end
    end
    get_params = get_params.to_a.sort_by { |a| a[0] }.reverse

    stop_delete = false
    get_params.delete_if do |a|
      index  = a[0]
      value  = a[1]
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

  # @return [Hash] default values for parameters
  def default_params
    @parameters.map do |array|
      array.map do |a|
        if a
          ['"', "'"].include?(a[0]) && ['"', "'"].include?(a[-1]) ? a[1..-2] : a
        else
          a
        end
      end
    end.to_h
  end

  private

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