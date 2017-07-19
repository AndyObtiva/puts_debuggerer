# puts_debuggerer v0.5.0 
[![Gem Version](https://badge.fury.io/rb/puts_debuggerer.svg)](http://badge.fury.io/rb/puts_debuggerer)
[![Build Status](https://travis-ci.org/AndyObtiva/puts_debuggerer.svg?branch=master)](https://travis-ci.org/AndyObtiva/puts_debuggerer)
[![Coverage Status](https://coveralls.io/repos/github/AndyObtiva/puts_debuggerer/badge.svg?branch=master)](https://coveralls.io/github/AndyObtiva/puts_debuggerer?branch=master)

Yes, many of us avoid debuggers like the plague and clamp on to our puts
statements like an umbrella in a stormy day.
Why not make it official and have puts debugging become its own perfectly
legitimate thing?!!

And thus, puts_debuggerer was born. A guilt-free puts debugger Ruby gem FTW!

In other words, puts_debuggerer is a Ruby library for improved puts debugging, automatically displaying bonus useful information such as source line number and source code.

Partially inspired (only partially ;) by this blog post:
https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html
(Credit to Tenderlove.)

Love PD?! Why not promote with [merchandise](https://www.zazzle.com/i+heart+pd+gifts)?

## Instructions

### Bundler

Add the following to bundler's `Gemfile`.

```ruby
gem 'puts_debuggerer', '~> 0.5.0'
```

### Manual

Or manually install and require library.

```bash
gem install puts_debuggerer -v0.5.0
```

```ruby
require 'puts_debuggerer'
```

### Usage

Simply invoke global `pd` method anywhere and it prints source file, line
number, and source code in addition to output (works even in IRB).
If the argument is a literal value with no interpolation, the print out is
simplified by not showing source code matching output.

Quickly locate printed lines using Find feature (e.g. CTRL+F) by looking for:
* [PD]
* file:line_number
* ruby expression.

This gives you the added benefit of easily removing your `pd` statements later
on.

This can easily be augmented with a print engine like [awesome_print](https://github.com/awesome-print/awesome_print) and
customized to format output differently as per options below.

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
   > pd "Show me the source of the bug: #{bug}"
  => "Show me the source of the bug: beattle"
[PD] /Users/User/finance_calculator_app/pd_test.rb:4 "What line number am I?"
```

### Options

Options enable more data to be displayed with puts_debuggerer, such as the caller
backtrace, header, and footer. They also allow customization of output format.

Options can be set as a global configuration or piecemeal per puts statement.

Global configuration is done via `PutsDebuggerer` module attribute writers.
On the other hand, piecemeal options can be passed to the `pd` global method as
the second argument.

Example:

```ruby
# File Name: /Users/User/project/piecemeal.rb
data = [1, [2, 3]]
pd data, header: '>'*80, footer: '<'*80, announcer: "   -<[PD]>-\n  "
```

Prints out:

```bash
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   -<[PD]>-
   /Users/User/project/piecemeal.rb:3
   > pd data
  => [1, [2, 3]]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
```

Details about all the available options are included below.

#### `PutsDebuggerer.app_path`
(default = `nil`)

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
   > pd "Show me the source of the bug: #{bug}"
  => "Show me the source of the bug: beattle"
[PD] pd_test.rb:5 "What line number am I?"
```

#### `PutsDebuggerer.header`
(default = `'*'*80`)

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
   > pd x=1
  => "1"
```

#### `PutsDebuggerer.footer`
(default = `'*'*80`)

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

Prints out:

```bash
[PD] /Users/User/example.rb:2
   > pd x=1
  => "1"
********************************************************************************
```

#### `PutsDebuggerer.print_engine`
(default = `:p`)

Print engine to use in object printout (e.g. `p`, `ap`, `pp`).
It is represented by the print engine's global method name as a symbol
(e.g. `:ap` for [awesome_print](https://github.com/awesome-print/awesome_print)).
Defaults to Ruby's built-in `p` method identified by the symbol `:p`.
If it finds [awesome_print](https://github.com/awesome-print/awesome_print) loaded, it defaults to `ap` as `:ap` instead.

Example:

```ruby
# File Name: /Users/User/example.rb
require 'awesome_print'
PutsDebuggerer.print_engine = :ap
array = [1, [2, 3]]
pd array
```

Prints out:

```bash
[PD] /Users/User/example.rb:5
   > pd array
  => [
    [0] 1,
    [1] [
        [0] 2,
        [1] 3
    ]
]
```

#### `PutsDebuggerer.announcer`
(default = `"[PD]"`)

Announcer (e.g. `[PD]`) to announce every print out with (default: `"[PD]"`)

Example:

```ruby
PutsDebuggerer.announcer = "*** PD ***\n  "
pd (x=1)
```

Prints out:

```bash
*** PD ***
   /Users/User/example.rb:2
   > pd x=1
  => "1"
```

#### `PutsDebuggerer.formatter`
(default = `PutsDebuggerer::FORMATTER_DEFAULT`)

Formatter used in every print out
Passed a data argument with the following keys:
* :announcer (string)
* :caller (array)
* :file (string)
* :footer (string)
* :header (string)
* :line_number (string)
* :pd_expression (string)
* :object (object)
* :object_printer (proc)

NOTE: data for :object_printer is not a string, yet a proc that must
be called to output value. It is a proc as it automatically handles usage
of print_engine and encapsulates its details. In any case, data for :object
is available should one want to avoid altogether.

Example:

```ruby
PutsDebuggerer.formatter = -> (data) {
  puts "-<#{data[:announcer]}>-"
  puts "HEADER: #{data[:header]}"
  puts "FILE: #{data[:file]}"
  puts "LINE: #{data[:line_number]}"
  puts "EXPRESSION: #{data[:pd_expression]}"
  print "PRINT OUT: "
  data[:object_printer].call
  puts "CALLER: #{data[:caller].to_a.first}"
  puts "FOOTER: #{data[:footer]}"
}
pd (x=1)
```

Prints out:

```bash
-<[PD]>-
FILE: /Users/User/example.rb
HEADER: ********************************************************************************
LINE: 9
EXPRESSION: x=1
PRINT OUT: 1
CALLER: #/Users/User/master_examples.rb:83:in `block (3 levels) in <top (required)>'
FOOTER: ********************************************************************************
```

#### `PutsDebuggerer.caller`
(default = nil)

Caller backtrace included at the end of every print out
Passed an argument of true/false, nil, or depth as an integer.
* true and -1 means include full caller backtrace
* false and nil means do not include caller backtrace
* depth (0-based) means include limited caller backtrace depth

Example:

```ruby
# File Name: /Users/User/sample_app/lib/sample.rb
PutsDebuggerer.caller = 3
pd (x=1)
```

Prints out:

```bash
[PD] /Users/User/sample_app/lib/sample.rb:3
    > pd x=1
   => "1"
     /Users/User/sample_app/lib/master_samples.rb:368:in \`block (3 levels) in <top (required)>\'
     /Users/User/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/irb/workspace.rb:87:in \`eval\'
     /Users/User/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/irb/workspace.rb:87:in \`evaluate\'
     /Users/User/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/irb/context.rb:381:in \`evaluate\'
```

### Bonus

puts_debuggerer comes with a number of bonus goodies.

It comes with [awesome_print](https://github.com/awesome-print/awesome_print).

You may disable by not requiring in Ruby or by adding an explicit reference to awesome_print with `require: false` in bundler:

```ruby
gem "awesome_print", require: false
gem "puts_debugger"
```

Additionally, puts_debuggerer comes with the following bonus utility methods:

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

* v0.5.0: custom formatter, caller backtrace, per-puts piecemeal options, and multi-line support
* v0.4.0: custom print engine (e.g. ap), custom announcer, and IRB support
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
