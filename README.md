# puts_debuggerer v0.7.1
[![Gem Version](https://badge.fury.io/rb/puts_debuggerer.svg)](http://badge.fury.io/rb/puts_debuggerer)
[![Build Status](https://travis-ci.org/AndyObtiva/puts_debuggerer.svg?branch=master)](https://travis-ci.org/AndyObtiva/puts_debuggerer)
[![Coverage Status](https://coveralls.io/repos/github/AndyObtiva/puts_debuggerer/badge.svg?branch=master)](https://coveralls.io/github/AndyObtiva/puts_debuggerer?branch=master)

Yes, many of us avoid debuggers like the plague and clamp on to our puts
statements like an umbrella in a stormy day.
Why not make it official and have puts debugging become its own perfectly
legitimate thing?!!

Enter puts_debuggerer. A guilt-free puts debugging Ruby gem FTW!

Partially inspired (only partially ;) by this blog post:
https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html
(Credit to Tenderlove.)

Love PD?! Why not promote with [merchandise](https://www.zazzle.com/i+heart+pd+gifts)? I'll buy everyone wearing this merchandise at conferences beer.

## Instructions

### Option 1: Bundler

Add the following to bundler's `Gemfile`.

```ruby
gem 'puts_debuggerer', '~> 0.7.1'
```

This is the recommended way for [Rails](rubyonrails.org) apps. Optionally, you may create an initializer under `config/initializers` named `puts_debuggerer_options.rb` to enable further customizations as per the [Options](#options) section below.

### Option 2: Manual

Or manually install and require library.

```bash
gem install puts_debuggerer -v0.7.1
```

```ruby
require 'puts_debuggerer'
```

### Usage

First, add `pd` method anywhere in your code to display details about an object or expression (if you're used to awesome_print, you're in luck! puts_debuggerer includes awesome_print as the default print engine for output).

Example:

```ruby
# /Users/User/finance_calculator_app/pd_test.rb           # line 1
bug = 'beattle'                                           # line 2
pd "Show me the source of the bug: #{bug}"                # line 3
pd "Show me the result of the calculation: #{(12.0/3.0)}" # line 4
```

Output:

```bash
[PD] /Users/User/finance_calculator_app/pd_test.rb:3
   > pd "Show me the source of the bug: #{bug}"
  => "Show me the source of the bug: beattle"
[PD] /Users/User/finance_calculator_app/pd_test.rb:4
   > pd "Show me the result of the calculation: #{(12.0/3.0)}"
  => "Show me the result of the calculation: 4.0"
```

In addition to the main object/expression output, you get to see the source file name, line number, and source code to help you debug and troubleshoot problems quicker (it even works in IRB).

Second, quickly locate printed lines using the Find feature (e.g. CTRL+F) by looking for:
* [PD]
* file:line_number
* known ruby expression.

Third, easily remove your ` pd ` statements via the source code Find feature once done debugging.

Note that `pd` returns the passed in object or expression argument unchanged, permitting debugging with shorter syntax than tap, and supporting chaining of extra method invocations afterward.

Example:

```ruby
# /Users/User/greeting_app/pd_test.rb                     # line 1
name = 'Robert'                                           # line 2
greeting = "Hello #{pd(name)}"                            # line 3
```

Output:

```bash
[PD] /Users/User/greeting_app/pd_test.rb:3
   > greeting = "Hello #{pd(name)}"
  => "Hello Robert"
```

Happy puts_debuggerering!

### Options

Options enable more data to be displayed with puts_debuggerer, such as the caller
backtrace, header, and footer. They also allow customization of output format.

Options can be set as a global configuration or piecemeal per puts statement.

Global configuration is done via `PutsDebuggerer` module attribute writers.
On the other hand, piecemeal options can be passed to the `pd` global method as
the second argument.

Example 1:

```ruby
# File Name: /Users/User/project/piecemeal.rb
data = [1, [2, 3]]
pd data, header: true
```

Prints out:

```bash
********************************************************************************
[PD] /Users/User/project/piecemeal.rb:3
   > pd data, header: true
  => [1, [2, 3]]
```

Example 2:

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
   > pd data, header: '>'*80, footer: '<'*80, announcer: "   -<[PD]>-\n  "
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
```

Example Printout:

```bash
[PD] /pd_test.rb:4
   > pd "Show me the source of the bug: #{bug}"
  => "Show me the source of the bug: beattle"
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
(default = `:ap`)

Print engine is a global method symbol or lambda expression to use in object printout. Examples of global methods are `:p`, `:ap`, and `:pp`. An example of a lambda expression is `lambda {|o| Rails.logger.info(o)}`

Defaults to [awesome_print](https://github.com/awesome-print/awesome_print). If it finds Rails loaded it defaults to `lambda {|o| Rails.logger.ap(o)}` instead

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

#### `PutsDebuggerer.run_at`
(default = nil)

Set condition for when to run as specified by an index, array, or range.
* Default value is `nil` meaning always
* Value as an Integer index (1-based) specifies at which run to print once
* Value as an Array of indices specifies at which runs to print multiple times
* Value as a range specifies at which runs to print multiple times,
  indefinitely if it ends with ..-1 or ...-1

Can be set globally via `PutsDebuggerer.run_at` or piecemeal via `pd object, run_at: run_at_value`

Global usage should be good enough for most cases. When there is a need to track
a single expression among several, you may add the option piecemeal, but it expects
the same exact `object` passed to `pd` for counting.

Examples (global):

```ruby
  PutsDebuggerer.run_at = 1
  pd (x=1) # prints standard PD output
  pd (x=1) # prints nothing

  PutsDebuggerer.run_at = 2
  pd (x=1) # prints nothing
  pd (x=1) # prints standard PD output

  PutsDebuggerer.run_at = [1, 3]
  pd (x=1) # prints standard PD output
  pd (x=1) # prints nothing
  pd (x=1) # prints standard PD output
  pd (x=1) # prints nothing

  PutsDebuggerer.run_at = 3..5
  pd (x=1) # prints nothing
  pd (x=1) # prints nothing
  pd (x=1) # prints standard PD output
  pd (x=1) # prints standard PD output
  pd (x=1) # prints standard PD output
  pd (x=1) # prints nothing
  pd (x=1) # prints nothing

  PutsDebuggerer.run_at = 3...6
  pd (x=1) # prints nothing
  pd (x=1) # prints nothing
  pd (x=1) # prints standard PD output
  pd (x=1) # prints standard PD output
  pd (x=1) # prints standard PD output
  pd (x=1) # prints nothing

  PutsDebuggerer.run_at = 3..-1
  pd (x=1) # prints nothing
  pd (x=1) # prints nothing
  pd (x=1) # prints standard PD output
  pd (x=1) # ... continue printing indefinitely on all subsequent runs

  PutsDebuggerer.run_at = 3...-1
  pd (x=1) # prints nothing
  pd (x=1) # prints nothing
  pd (x=1) # prints standard PD output
  pd (x=1) # ... continue printing indefinitely on all subsequent runs
```

You may reset the run_at number counter via:
`PutsDebuggerer.reset_run_at_global_number` for global usage.

And:
`PutsDebuggerer.reset_run_at_number` or
`PutsDebuggerer.reset_run_at_numbers`
for piecemeal usage.

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

* v0.7.1: default print engine to :ap (AwesomePrint)
* v0.7.0: `run_at` option, global and piecemeal.
* v0.6.1: updated README and broke apart specs
* v0.6.0: unofficial erb support, returning evaluated object/expression, removed static syntax support (replaced with header support)
* v0.5.1: support for print engine lambdas and smart defaults for leveraging Rails and AwesomePrint debuggers in Rails
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
