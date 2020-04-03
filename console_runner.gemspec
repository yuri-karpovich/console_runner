# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'console_runner/version'

Gem::Specification.new do |spec|
  spec.name    = 'console_runner'
  spec.version = ConsoleRunner::VERSION
  spec.authors = ['Yury Karpovich']
  spec.email   = %w(spoonest@gmail.com yuri.karpovich@gmail.com)

  spec.summary     = 'Command-line runner for ruby code.'
  spec.description = 'This gem provides you an ability to run any Ruby method ' \
    'from command-line (no any code modifications required!!!)'
  spec.homepage    = 'https://github.com/yuri-karpovich/console_runner'
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = ['c_run']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.1'

  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'rb-readline', '~> 0'
  spec.add_development_dependency 'simplecov', '~> 0'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_dependency 'optimist', '~> 3.0'
  spec.add_dependency 'yard', '~> 0.9'
  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'tty-logger', '~> 0'
end