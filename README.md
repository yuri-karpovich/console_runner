# ConsoleRunner
[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]
[![Dependency Status][DS img]][Dependency Status]
[![Code Climate][CC img]][Code Climate]
[![Coverage Status][CS img]][Coverage Status]

This gem provides you an ability to run any Ruby method from command-line. No special code modifications required!.
`console_runner` is a smart mix of [YARD](http://yardoc.org/) and [Trollop](http://manageiq.github.io/trollop/) gems. 
> 1. it parses [YARD](http://yardoc.org/) annotations of classes and methods to 'understand' your code
> 2. it generates friendly unix-like help menu for your tool (using [Trollop](http://manageiq.github.io/trollop/) gem)
> 3. it parses command-line input and run your Ruby code in a proper way 

Just 4 simple steps to make your code runnable from terminal:
1. Just add `@runnable` tag in 

One thing you need to do is to add an [YARD](http://yardoc.org/) tag annotation `@runnable`.

## Usage
`console_runner` extends [YARD](http://yardoc.org/) with a new tag: `@runnable`. You need to set this tag in a Class and Method annotation. After that it will be possible to call this method from command-line.
Usage instructions are as simple as one, two, three:
1. Add `@runnable` tag
2. Now you can run your tool from terminal by `c_run /path/to/class.rb_file` command
3. PROFIT! (: 

### Example
1. Install `console_runner` gem
2. Put some code to `/home/user/project/my_class.rb`
```ruby
# @runnable
class MyClass

    # @runnable
    def say_hello
      puts 'Hello!'
    end
    
end
```
3. Run terminal command to run `say_hello` method
```bash
c_run /home/user/project/my_class.rb say_hello

-> Hello!
```

Read FAQ for more examples.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'console_runner'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install console_runner

## FAQ
#### **Can I add documentation for my tool and customize help page content?**
Yes. Any text placed after `@runnable` tag will be displayed on the help page. You can add any additional information about how to use your tool there.
> **Tip**: You can use multi-line text as well

**Example:**
```ruby
# @runnable This tool can talk to you. Run it when you are lonely.
class MyClass

    def initialize
      @hello_msg = 'Hello!' 
      @bye_msg = 'Good Bye!' 
    end
    
    # @runnable Say 'Hello' to you.
    def say_hello
      puts @hello_msg
    end
    
    # @runnable Say 'Good Bye' to you.
    def say_bye
      puts @bye_msg
    end
    
end
```

```bash
TODO example
```

## ToDo
- fix help menu for action: action help text should be displayed, list of available actions should be displayed

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