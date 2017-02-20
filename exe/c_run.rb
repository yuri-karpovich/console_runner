#!/usr/bin/env ruby

require_relative '../test/simple_cov' if ENV['C_RUNNER_SCOV'].to_s == 'true'

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)
require 'console_runner'

