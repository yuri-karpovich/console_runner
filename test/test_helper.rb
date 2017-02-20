$LOAD_PATH.unshift File.expand_path('../../exe', __FILE__)
require 'minitest/autorun'
require 'simplecov'
SimpleCov.start do
  filters.clear # This will remove the :root_filter and :bundler_filter that come via simplecov's defaults
  add_filter do |src|
    !(src.filename =~ /^#{SimpleCov.root}/) if src.filename =~ /vendor/
    # !(src.filename =~ /^#{SimpleCov.root}/) unless src.filename =~ /vendor/
  end
  add_filter "/vendor/"
end
