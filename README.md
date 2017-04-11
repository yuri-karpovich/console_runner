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

TODO: Write usage instructions here

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
[CS img]: https://coveralls.io/repos/github/yuri-karpovich/console_runner/badge.svg