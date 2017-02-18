# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'console_runner/version'

Gem::Specification.new do |spec|
  spec.name          = "console_runner"
  spec.version       = ConsoleRunner::VERSION
  spec.authors       = ["Yury Karpovich"]
  spec.email         = ["spoonest@gmail.com"]

  spec.summary       = %q{Terminal runner for ruby code.}
  spec.description   = %q{The gem provides ability to execute any ruby class method without special code modifying}
  spec.homepage      = "https://github.com/yuri-karpovich"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = ["c_run"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry"
  spec.add_dependency "trollop"
  spec.add_dependency "yard", "~> 0.9"
  # spec.add_dependency "awesome_print", "~> 1.7"
  # spec.add_dependency "colorize"

end
