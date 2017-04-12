# ConsoleRunner
[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]
[![Dependency Status][DS img]][Dependency Status]
[![Code Climate][CC img]][Code Climate]
[![Coverage Status][CS img]][Coverage Status]

This gem provides you an ability to run any Ruby method from command-line (no any code modifications required!!!).
One thing you need to do is to add an [YARD](http://yardoc.org/) tag annotation `@runnable`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'console_runner'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install console_runner

## Usage
Usage is simple. First of all you need to add `gem 'console_runner'` in your `Gemfile`.
Then you need to specify `@runnable` tag in your class and method annotations. For example,
 
```ruby
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
# @runnable This is your "smart" assistant tool.
#   NOTE: This message will be shown in your tool in --help menu.
#
# @since 0.1.0
class SimpleSiri

  def initialize
    @name = 'Siri'
    @age = Random.rand 100
  end

  # Say something
  #
  # @runnable
  # @return [String]
  # @param [String] what_to_say ask name or age of Siri
  def say(what_to_say)
    case what_to_say.downcase
      when 'name'
        puts 'My name is ' + @name
      when 'age'
        puts "I'm #{@age} years old"
      else
        puts "I don't know".green
    end
  end

end
```

Then you can run the tool in your console:
```bash
c_run ruby_class.rb say --help

This is your "smart" assistant tool.
NOTE: This message will be shown in your tool in --help menu.
  -h, --help               Show this message
  -w, --what-to-say=<s>    (Ruby class: String) ask name or age of Siri
```

```bash
 c_run ruby_class.rb say -w age
 
=======================================================
Global options:
     help = false
INIT: initialize
INIT options:

Subcommand: say
Subcommand options:
     what_to_say = age
=======================================================
Start Time: 2017-04-11 21:39:40 +0300
I'm 78 years old
Finish Time: 2017-04-11 21:39:40 +0300 (Duration: 0.0 minutes)

```

## ToDo
- fix help menu for action: action help text should be displayed.
- add tests for same methods naming
- write good readme

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuri-karpovich/console_runner.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


[Gem Version]: https://rubygems.org/gems/console_runner
[Build Status]: https://travis-ci.org/yuri-karpovich/console_runner
[travis pull requests]: https://travis-ci.org/yuri-karpovich/console_runner/pull_requests
[Dependency Status]: https://gemnasium.com/github.com/yuri-karpovich/console_runner
[Code Climate]: https://codeclimate.com/github/yuri-karpovich/console_runner
[Coverage Status]: https://coveralls.io/github/yuri-karpovich/console_runner

[GV img]: https://badge.fury.io/rb/console_runner.svg
[BS img]: https://travis-ci.org/yuri-karpovich/console_runner.svg?branch=master
[DS img]: https://gemnasium.com/badges/github.com/yuri-karpovich/console_runner.svg
[CC img]: https://codeclimate.com/github/yuri-karpovich/console_runner.png
[CS img]: https://coveralls.io/repos/github/yuri-karpovich/console_runner/badge.svg?branch=master