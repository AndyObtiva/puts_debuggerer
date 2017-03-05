# puts_debuggerer v0.3.0
[![Gem Version](https://badge.fury.io/rb/puts_debuggerer.svg)](http://badge.fury.io/rb/puts_debuggerer)
[![Build Status](https://travis-ci.org/AndyObtiva/puts_debuggerer.svg?branch=master)](https://travis-ci.org/AndyObtiva/puts_debuggerer)
[![Coverage Status](https://coveralls.io/repos/github/AndyObtiva/puts_debuggerer/badge.svg?branch=master)](https://coveralls.io/github/AndyObtiva/puts_debuggerer?branch=master)

Ruby tools for improved puts debugging, automatically displaying bonus useful information such as file, line number and source code.

Partially inspired by this blog post:
https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html
(Credit to Tenderlove.)

## Instructions

### Bundler

Add the following to bundler's `Gemfile`.

```ruby
gem 'puts_debuggerer', '~> 0.2.0'
```

### Manual

Or manually install and require library.

```bash
gem install puts_debuggerer -v0.2.0
```

```ruby
require 'puts_debuggerer'
```

### Usage

Simply invoke global `pd` method anywhere you'd like to see line number and source code with output.
If the argument is a pure string, the print out is simplified by not showing duplicate source.

Quickly locate printed lines using Find feature (e.g. CTRL+F) by looking for:
* [PD]
* file:line_number
* ruby expression.

This gives you the added benefit of easily removing your pd statements later on from the code.

Happy puts_debuggerering!

Example Code:

```ruby
# /Users/User/finance_calculator_app/pd_test.rb # line 1
bug = 'beattle'                                 # line 2
pd "Show me the source of the bug: #{bug}"      # line 3
pd 'What line number am I?'                     # line 4
```

Example Printout:

```bash
[PD] /Users/User/finance_calculator_app/pd_test.rb:3
   > ("Show me the source of the bug: #{bug}").inspect
  => "Show me the source of the bug: beattle"
[PD] /Users/User/finance_calculator_app/pd_test.rb:4 "What line number am I?"
```

### Options

#### `PutsDebuggerer.app_path`

Sets absolute application path. Makes `pd` file output relative to it.
If [Rails](rubyonrails.org) was detected, it is automatically defaulted to `Rails.root.to_s`

```ruby
# /Users/User/finance_calculator_app/pd_test.rb                                 # line 1
PutsDebuggerer.app_path = File.join('/Users', 'User', 'finance_calculator_app') # line 2
bug = 'beattle'                                                                 # line 3
pd "Show me the source of the bug: #{bug}"                                      # line 4
pd 'What line number am I?'                                                     # line 5
```

Example Printout:

```bash
[PD] pd_test.rb:4
   > ("Show me the source of the bug: #{bug}").inspect
  => "Show me the source of the bug: beattle"
[PD] pd_test.rb:5 "What line number am I?"
```

#### `PutsDebuggerer.header`

Header to include at the top of every print out.
* Default value is `nil`
* Value `true` enables header as `'*'*80`
* Value `false`, `nil`, or empty string disables header
* Any other string value gets set as a custom header

Example:

```ruby
PutsDebuggerer.header = true
pd (x=1)
```

Prints out:

```bash
********************************************************************************
[PD] /Users/User/example.rb:2
   > (x=1).inspect
  => "1"
```

#### `PutsDebuggerer.footer`

Footer to include at the bottom of every print out.
* Default value is `nil`
* Value `true` enables footer as `'*'*80`
* Value `false`, `nil`, or empty string disables footer
* Any other string value gets set as a custom footer

Example:

```ruby
PutsDebuggerer.footer = true
pd (x=1)
```

Prints out

```bash
[PD] /Users/User/example.rb:2
   > (x=1).inspect
  => "1"
********************************************************************************
```

### Bonus

puts_debuggerer comes with the following bonus utility methods:

#### `__caller_line_number__(caller_depth=0)`

Provides caller line number starting 1 level above caller of this method (with default `caller_depth=0`).

Example:

```ruby
# File Name: lib/example.rb             # line 1
# Print out __caller_line_number__      # line 2
puts __caller_line_number__             # line 3
```

Prints out `3`


#### `__caller_file__(caller_depth=0)`

Provides caller file starting 1 level above caller of this method (with default `caller_depth=0`).

Example:

```ruby
# File Name: lib/example.rb
puts __caller_file__
```

Prints out `lib/example.rb`

#### `__caller_source_line__(caller_depth=0)`

Provides caller source line starting 1 level above caller of this method (with default `caller_depth=0`).

Example:

```ruby
puts __caller_source_line__
```

Prints out `puts __caller_source_line__`

## Release Notes

* v0.3.0: header/footer support, multi-line printout, improved format
* v0.2.0: App path exclusion support, Rails root support, improved format
* v0.1.0: File/line/expression print out

## Contributing

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Change directory into project
* Run `gem install bundler && bundle && rake` and make sure RSpec tests are passing
* Start a feature/bugfix branch.
* Write RSpec tests, Code, Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2017 Andy Maleh. See LICENSE.txt for
further details.
