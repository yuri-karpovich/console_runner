require 'simplecov'
SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/test/"
end
SimpleCov.command_name "Test:#{Process.pid}"