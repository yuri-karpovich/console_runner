class AssetBase

  SUCCESS_EXIT_CODE = 20
  INITIALIZER_MESSAGE = 'IN INITIALIZE METHOD'
  ACTION_MESSAGE = 'IN ACTION METHOD'
  CLASS_ACTION_MESSAGE = 'IN CLASS ACTION METHOD'

  def initialize
    puts INITIALIZER_MESSAGE
  end

  def action
    puts ACTION_MESSAGE
  end

  def self.class_action
    puts CLASS_ACTION_MESSAGE
  end

end