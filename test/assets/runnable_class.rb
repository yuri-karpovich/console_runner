require_relative './exit_codes'

# This is basic Ruby class with YARD annotation.
# Nothing special here except @runnable tag. This is a `console_runner` tag that
# shows that this class can be runnable via bash command line.
#
# You can mark any method (class method or instance method) with @runnable tag to show you want the method to be executable.
# We name class method as *class action* and instance method as *instance action* or just *action*.
# Instance action requires #initialize method to be executed first. `console_runner` tool invokes #initialize
# method automatically.
#
# @author Yuri Karpovich
#
# @runnable Here you can specify you tool description. This message will be shown in your tool in --help menu.
#   You can use multiline text as well.
#
# @since 0.1.0
class RunnableClass
  include ExitCodes
  INITIALIZER_MESSAGE  = 'IN INITIALIZE METHOD'.freeze
  ACTION_MESSAGE       = 'IN ACTION METHOD'.freeze
  CLASS_ACTION_MESSAGE = 'IN CLASS ACTION METHOD'.freeze
  DEFAULT_CONSTANT     = 'default'.freeze

  # This method is executed in case you perform instance action.
  # It's not necessary to mark this method with @runnable tag.
  def initialize
    puts INITIALIZER_MESSAGE
  end

  # This is instance action you may perform.
  #
  # @runnable This text will be shown in action --help menu.
  # @param [String] parameter Parameter name
  def single_param_action(parameter)
    action :single_param_action
  end

  # @runnable
  # @param [String] parameter Parameter name
  # @param [String] another_param another parameter name
  def two_params_action(parameter, another_param)
    action :two_params_action
  end

  # @runnable
  # @param [String] parameter Parameter name
  # @param [String] another_param another parameter name
  def two_params_action_one_default(another_param, parameter = 'default')
    action :two_params_action_one_default
  end

  # @runnable This text will be shown in action --help menu.
  #
  # @param [String] parameter Parameter name
  # @param [Hash] options options
  # @option options [String] :first_option option name
  # @option options [String] :second_option option name
  def action_with_options(parameter, options = {})
    action :action_with_options
  end

  # @param [String] parameter Parameter name
  def action_not_runnable(parameter)
    action :action_not_runnable
  end

  # @runnable
  def no_param_action
    action :no_param_action
  end

  # This is class action you may perform.
  #
  # @runnable This text will be shown in class action --help menu.
  # @param [String] parameter name of parameter
  def self.class_single_param_action(parameter)
    class_action :class_single_param_action
  end

  # @runnable
  # @param [String] parameter Parameter name
  # @param [String] another_param another parameter name
  def self.class_two_params_action(parameter, another_param)
    class_action :class_two_params_action
  end


  # @runnable
  # @param [String] parameter Parameter name
  # @param [String] another_param another parameter name
  def self.class_two_params_action_one_default(another_param, parameter = 'default')
    class_action :class_two_params_action_one_default
  end

  # @runnable This text will be shown in action --help menu.
  #
  # @param [String] parameter Parameter name
  # @param [Hash] options options
  # @option options [String] :first_option option name
  # @option options [String] :second_option option name
  def self.class_action_with_options(parameter, options = {})
    class_action :class_action_with_options
  end

  # @param [String] parameter Parameter name
  def self.class_action_not_runnable(parameter)
    class_action :class_action_not_runnable
  end

  # @runnable
  def self.class_no_param_action
    class_action :class_no_param_action
  end


  # @runnable
  def same_name_action
    action :same_name_action
  end

  # @runnable
  def self.same_name_action
    class_action :class_same_name_action
  end

  # @runnable
  #
  # @param [String] parameter Parameter name
  # @param [Hash] options options
  # @option options [String] :first_option option name
  # @option options [String] :parameter parameter name
  def same_param_name_action(parameter, options = {})
    action :same_param_name_action
  end

  # @runnable
  #
  # @param [String] parameter Parameter name
  # @param [Hash] options options
  # @option options [String] :first_option option name
  # @option options [String] :parameter parameter name
  def self.class_same_param_name_action(parameter, options = {})
    class_action :class_same_param_name_action
  end

  # @runnable
  #
  # @param [String] parameter_one Parameter 1 name
  # @param [String] parameter_two Parameter 2 name
  def self.class_constant_in_param(parameter_one, parameter_two = DEFAULT_CONSTANT)
    class_action :class_constant_in_param
  end

  # @runnable
  #
  # @param [String] parameter_one Parameter 1 name
  # @option options [String] :first_option option name
  # @option options [String] :parameter parameter name
  def self.class_constant_in_options(parameter_one, options = { first_option: DEFAULT_CONSTANT })
    class_action :class_constant_in_options
  end


  # @runnable
  #
  # @param [String] parameter_one Parameter 1 name
  # @param [String] parameter_two Parameter 2 name
  def constant_in_param(parameter_one, parameter_two = DEFAULT_CONSTANT)
    action :constant_in_param
  end

  # @runnable
  #
  # @param [String] parameter_one Parameter 1 name
  # @option options [String] :first_option option name
  # @option options [String] :parameter parameter name
  def constant_in_options(parameter_one, options = { first_option: DEFAULT_CONSTANT })
    action :constant_in_options
  end

  private

  def action(action_key)
    action_name = action_key
    puts "#{ACTION_MESSAGE}: #{action_name}"
    exit EXIT_CODES[action_name]
  end

  def self.class_action(action_key)
    action_name = action_key
    puts "#{CLASS_ACTION_MESSAGE}: #{action_name}"
    exit EXIT_CODES[action_name]
  end

  # @runnable Say 'Hello' to you.
  # @param [String] name Your name
  # @param [Hash] options options
  # @option options [Boolean] :second_meet Have you met before?
  # @option options [String] :prefix Your custom prefix
  def say_hello(name, options = {})
    second_meet = nil
    second_meet = 'Nice to see you again!' if options['second_meet']
    prefix      = options['prefix']
    message     = 'Hello, '
    message     += "#{prefix} " if prefix
    message     += "#{name}. "
    message     += second_meet if second_meet
    puts message
    exit EXIT_CODES[:say_hello]
  end
end