require_relative './exit_codes'

# @runnable
class RunnableClassWOInit
  include ExitCodes
  INITIALIZER_MESSAGE  = 'IN INITIALIZE METHOD'.freeze
  ACTION_MESSAGE       = 'IN ACTION METHOD'.freeze
  CLASS_ACTION_MESSAGE = 'IN CLASS ACTION METHOD'.freeze

  # @runnable
  def action_without_init
    action :action_without_init
  end

  private

  def action(action_key)
    action_name = action_key
    puts "#{ACTION_MESSAGE}: #{action_name}"
    exit EXIT_CODES[action_name]
  end

end
