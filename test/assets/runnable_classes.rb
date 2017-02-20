require_relative '../assets/asset_base'

# This is common Ruby class with common YARD annotation.
# Nothing special here except @runnable tag. This is a `console_runner` tag that shows that this class can be runnable
# via bash command line.
#
# You can mark any method (class method or instance method) with @runnable tag to show you want the method to be executable.
# We name class method as *class action* and instance method as *instance action* or *action*.
# Instance action requires #initialize method to be executed first. `console_runner` tool invokes #initialize
# method automatically.
#
# @author Yuri Karpovich
#
# @runnable Here you can specify you tool description. This message will be shown in your tool in --help menu.
#   You can use multiline text as well.
#
# @since 0.1.0
class RunnableClass < AssetBase

  # This method is executed in case you perform instance action. It's not necessary to mark this method with @runnable tag.
  # @param [String] text INIT METHOD
  def initialize
    super
  end

  # This is instance action you may perform.
  #
  # @runnable This text will be shown in action --help menu.
  #
  # @param [String] server  name of server
  # @param [Array(String)] array_or_strings  array of strings example
  # @param [Hash] options2 options
  # @option options2 [String] :delivery_name Name of delivery (required).
  # @option options2 [String] :delivery_type :monthly, :weekly, :daily
  # @option options2 [String] :customer_name Name of customer (required).
  # @option options2 [String] :name Name of validated site. Accessible through tokens (required).
  # @option options2 [Fixnum] :scenario Cucumber scenario object. Used fot tmp directory generation (required).
  # @option options2 [String] :jira_project_key JIRA project key (optional).
  # @option options2 [Boolean] :build_time Time used to generate tokens such as $WEEK, $DAY_OF_WEEK. Current time is used by default (optional).
  def action(server=1, array_or_strings=2, options2={} )
    super()
  end

  # This is class action you may perform.
  #
  # @runnable This text will be shown in class action --help menu.
  # @param [String] server  name of server
  def self.class_action(server= 1)
    super()
  end

end