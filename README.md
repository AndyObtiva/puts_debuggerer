# Puts Debuggerer (debugger-less debugging FTW)
[![Gem Version](https://badge.fury.io/rb/puts_debuggerer.svg)](http://badge.fury.io/rb/puts_debuggerer)
[![Build Status](https://travis-ci.org/AndyObtiva/puts_debuggerer.svg?branch=master)](https://travis-ci.org/AndyObtiva/puts_debuggerer)
[![Coverage Status](https://coveralls.io/repos/github/AndyObtiva/puts_debuggerer/badge.svg?branch=master)](https://coveralls.io/github/AndyObtiva/puts_debuggerer?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/81d8f6e046eb1b4a36f4/maintainability)](https://codeclimate.com/github/AndyObtiva/puts_debuggerer/maintainability)

(credit to Aaron Patterson for partial inspiration: https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html)

Debuggers are great! They help us troubleshoot complicated programming problems by inspecting values produced by code, line by line. They are invaluable when trying to understand what is going on in a large application composed of thousands or millions of lines of code.

In day-to-day test-driven development and simple app debugging though, a puts statement can be a lot quicker in revealing what is going on than halting execution completely just to inspect a single value or a few. This is certainly true when writing the simplest possible code that could possibly work, and running a test every few seconds or minutes. Still, there are a number of problems with puts debugging, like difficulty in locating puts statements in a large output log, knowing which methods and line numbers were invoked, identifying which variables were printed, and seeing the content of structured hashes and arrays in an understandable format.

Enter [puts_debuggerer](https://rubygems.org/gems/puts_debuggerer)! A guilt-free puts debugging Ruby gem FTW that prints file names, line numbers, code statements, headers, footers, stack traces, and formats output nicely courtesy of [awesome_print](https://rubygems.org/gems/awesome_print).

[puts_debuggerer](https://rubygems.org/gems/puts_debuggerer) automates tips mentioned in [this blog post](https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html) by Aaron Patterson.

Basic Example:

```ruby
# /Users/User/trivia_app.rb      # line 1
require 'pd'                     # line 2
bug_or_band = 'beattle'          # line 3
pd bug_or_band                   # line 4
```

Output:

```bash
[PD] /Users/User/trivia_app.rb:4
   > pd bug_or_band                   # line 4
  => "beattle"
```

## Background

It can be quite frustrating to lose puts statements in a large output or log file. One way to help find them is add an announcer (e.g. `puts "The Order Total"`) or a header (e.g. `puts '*'*80`) before every puts statement. Unfortunately, that leads to repetitive wasteful effort that adds up quickly over many work sessions and interrupts thinking flow while solving problems.

puts_debuggerer automates that work via the short and simple `pd` command, automatically printing meaningful headers for output and accelerating problem solving work due to ease of typing.

Example without pd:

```ruby
puts order_total
```

Output:
```
195.50
```

Which gets lost in a logging stream such as:

```
   (2.7ms)  CREATE TABLE "ar_internal_metadata" ("key" character varying PRIMARY KEY, "value" character varying, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL)
  ActiveRecord::InternalMetadata Load (0.4ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
   (0.2ms)  BEGIN
  SQL (0.3ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "key"  [["key", "environment"], ["value", "development"], ["created_at", 2017-08-24 22:56:52 UTC], ["updated_at", 2017-08-24 22:56:52 UTC]]
   (0.3ms)  COMMIT
   195.50
  ActiveRecord::InternalMetadata Load (0.3ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
   (0.2ms)  BEGIN
   (0.2ms)  COMMIT
```

Problem can be mitigated by adding a few more puts statements:

```ruby
puts "*"*40
puts "order_total"
puts order_total
```

But those add up pretty quickly when inspecting multiple variables:

```ruby
puts "*"*40
puts "order_total"
puts order_total
puts "*"*40
puts "order_summary"
puts order_summary
puts "*"*40
puts "order_details"
puts order_details
```

Here is a simple example using `pd` instead, which provides everything the puts statements above provide in addition to deducing the file name and line number automatically for dead easy debugging:

```ruby
pd order_total
```

Output:

```
[PD] /Users/User/ordering/order.rb:39
  > pd order_total  
 => 195.50
```

This is not only easy to locate in a logging stream such as the one below, but also announces the `order_total` variable with `[PD]` for easy findability among other pd statements (you may always enter `[PD]` or variable name `order_total` using the CMD+F Quick Find to instantly jump to that line in the log):

```ruby
pd order_total
pd order_summary
pd order_details
```

Output:

```
   (2.7ms)  CREATE TABLE "ar_internal_metadata" ("key" character varying PRIMARY KEY, "value" character varying, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL)
  ActiveRecord::InternalMetadata Load (0.4ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
[PD] /Users/User/ordering/order.rb:39
  > pd order_total  
 => 195.50
   (0.2ms)  BEGIN
  SQL (0.3ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "key"  [["key", "environment"], ["value", "development"], ["created_at", 2017-08-24 22:56:52 UTC], ["updated_at", 2017-08-24 22:56:52 UTC]]
   (0.3ms)  COMMIT
[PD] /Users/User/ordering/order.rb:40
  > pd order_summary  
 => "Pragmatic Ruby Book"
  ActiveRecord::InternalMetadata Load (0.3ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
   (0.2ms)  BEGIN
   (0.2ms)  COMMIT
[PD] /Users/User/ordering/order.rb:41
  > pd order_details  
 => "[Hard Cover] Pragmatic Ruby Book - English Version"
```

What if you would like to add a header for faster findability? Just use the `header` option:

```ruby
pd order_total, header: true
pd order_summary
pd order_details
```

Output:

```
   (2.7ms)  CREATE TABLE "ar_internal_metadata" ("key" character varying PRIMARY KEY, "value" character varying, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL)
  ActiveRecord::InternalMetadata Load (0.4ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
********************************************************************************
[PD] /Users/User/ordering/order.rb:39
  > pd order_total, header: true
 => 195.50
   (0.2ms)  BEGIN
  SQL (0.3ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "key"  [["key", "environment"], ["value", "development"], ["created_at", 2017-08-24 22:56:52 UTC], ["updated_at", 2017-08-24 22:56:52 UTC]]
   (0.3ms)  COMMIT
[PD] /Users/User/ordering/order.rb:40
  > pd order_summary  
 => "Pragmatic Ruby Book"
  ActiveRecord::InternalMetadata Load (0.3ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
   (0.2ms)  BEGIN
   (0.2ms)  COMMIT
[PD] /Users/User/ordering/order.rb:41
  > pd order_details  
 => "[Hard Cover] Pragmatic Ruby Book - English Version"
```

Wanna customize the header and add a footer too? No problem:

```ruby
pd order_total, header: '>'*80
pd order_summary
pd order_details, footer: '<'*80
```

Output:

```
   (2.7ms)  CREATE TABLE "ar_internal_metadata" ("key" character varying PRIMARY KEY, "value" character varying, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL)
  ActiveRecord::InternalMetadata Load (0.4ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
[PD] /Users/User/ordering/order.rb:39
  > pd order_total, header: '>'*80
 => 195.50
   (0.2ms)  BEGIN
  SQL (0.3ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "key"  [["key", "environment"], ["value", "development"], ["created_at", 2017-08-24 22:56:52 UTC], ["updated_at", 2017-08-24 22:56:52 UTC]]
   (0.3ms)  COMMIT
[PD] /Users/User/ordering/order.rb:40
  > pd order_summary  
 => "Pragmatic Ruby Book"
  ActiveRecord::InternalMetadata Load (0.3ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
   (0.2ms)  BEGIN
   (0.2ms)  COMMIT
[PD] /Users/User/ordering/order.rb:41
  > pd order_details, footer: '<'*80  
 => "[Hard Cover] Pragmatic Ruby Book - English Version"
 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
```

Need a quick stack trace? Just use the `caller` option (you may surround with header and footer too via `wrapper`).

```ruby
pd order_total, caller: true, wrapper: true
pd order_summary
pd order_details
```

Output:

```
   (2.7ms)  CREATE TABLE "ar_internal_metadata" ("key" character varying PRIMARY KEY, "value" character varying, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL)
  ActiveRecord::InternalMetadata Load (0.4ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
********************************************************************************
[PD] /Users/User/ordering/order.rb:39
  > pd order_total, caller: true, wrapper: true
 => 195.50
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:23:in `require'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:23:in `block in require_with_bootsnap_lfi'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/loaded_features_index.rb:92:in `register'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:22:in `require_with_bootsnap_lfi'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:31:in `require'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/activesupport-5.2.4.3/lib/active_support/dependencies.rb:291:in `block in require'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/activesupport-5.2.4.3/lib/active_support/dependencies.rb:257:in `load_dependency'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/activesupport-5.2.4.3/lib/active_support/dependencies.rb:291:in `require'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/railties-5.2.4.3/lib/rails/commands/server/server_command.rb:145:in `block in perform'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/railties-5.2.4.3/lib/rails/commands/server/server_command.rb:142:in `tap'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/railties-5.2.4.3/lib/rails/commands/server/server_command.rb:142:in `perform'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/thor-1.0.1/lib/thor/command.rb:27:in `run'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/thor-1.0.1/lib/thor/invocation.rb:127:in `invoke_command'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/thor-1.0.1/lib/thor.rb:392:in `dispatch'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/railties-5.2.4.3/lib/rails/command/base.rb:69:in `perform'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/railties-5.2.4.3/lib/rails/command.rb:46:in `invoke'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/railties-5.2.4.3/lib/rails/commands.rb:18:in `<main>'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:23:in `require'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:23:in `block in require_with_bootsnap_lfi'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/loaded_features_index.rb:92:in `register'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:22:in `require_with_bootsnap_lfi'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:31:in `require'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/activesupport-5.2.4.3/lib/active_support/dependencies.rb:291:in `block in require'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/activesupport-5.2.4.3/lib/active_support/dependencies.rb:257:in `load_dependency'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/activesupport-5.2.4.3/lib/active_support/dependencies.rb:291:in `require'
     /Users/User/code/sample-glimmer-dsl-opal-rails5-app/bin/rails:9:in `<top (required)>'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/spring-2.1.0/lib/spring/client/rails.rb:28:in `load'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/spring-2.1.0/lib/spring/client/rails.rb:28:in `call'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/spring-2.1.0/lib/spring/client/command.rb:7:in `call'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/spring-2.1.0/lib/spring/client.rb:30:in `run'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/spring-2.1.0/bin/spring:49:in `<top (required)>'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/spring-2.1.0/lib/spring/binstub.rb:11:in `load'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/spring-2.1.0/lib/spring/binstub.rb:11:in `<top (required)>'
     /Users/User/code/sample-glimmer-dsl-opal-rails5-app/bin/spring:15:in `require'
     /Users/User/code/sample-glimmer-dsl-opal-rails5-app/bin/spring:15:in `<top (required)>'
     bin/rails:3:in `load'
     bin/rails:3:in `<main>'
********************************************************************************
   (0.2ms)  BEGIN
  SQL (0.3ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "key"  [["key", "environment"], ["value", "development"], ["created_at", 2017-08-24 22:56:52 UTC], ["updated_at", 2017-08-24 22:56:52 UTC]]
   (0.3ms)  COMMIT
[PD] /Users/User/ordering/order.rb:40
  > pd order_summary  
 => "Pragmatic Ruby Book"
  ActiveRecord::InternalMetadata Load (0.3ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
   (0.2ms)  BEGIN
   (0.2ms)  COMMIT
[PD] /Users/User/ordering/order.rb:41
  > pd order_details  
 => "[Hard Cover] Pragmatic Ruby Book - English Version"
```

Is the stack trace too long? Shorten it by passing number of lines to display to `caller` option.

```ruby
pd order_total, caller: 3, wrapper: true
pd order_summary
pd order_details
```

```
   (2.7ms)  CREATE TABLE "ar_internal_metadata" ("key" character varying PRIMARY KEY, "value" character varying, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL)
  ActiveRecord::InternalMetadata Load (0.4ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
********************************************************************************
[PD] /Users/User/ordering/order.rb:39
  > pd order_total, caller: 3, wrapper: true 
 => 195.50
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:23:in `require'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:23:in `block in require_with_bootsnap_lfi'
     /Users/User/.rvm/gems/ruby-2.7.1/gems/bootsnap-1.4.6/lib/bootsnap/load_path_cache/loaded_features_index.rb:92:in `register'
********************************************************************************
   (0.2ms)  BEGIN
  SQL (0.3ms)  INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "key"  [["key", "environment"], ["value", "development"], ["created_at", 2017-08-24 22:56:52 UTC], ["updated_at", 2017-08-24 22:56:52 UTC]]
   (0.3ms)  COMMIT
[PD] /Users/User/ordering/order.rb:40
  > pd order_summary  
 => "Pragmatic Ruby Book"
  ActiveRecord::InternalMetadata Load (0.3ms)  SELECT  "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", :environment], ["LIMIT", 1]]
   (0.2ms)  BEGIN
   (0.2ms)  COMMIT
[PD] /Users/User/ordering/order.rb:41
  > pd order_details  
 => "[Hard Cover] Pragmatic Ruby Book - English Version"
```

There are many more options and powerful features in [puts_debuggerer](https://rubygems.org/gems/puts_debuggerer) as detailed below.

## Instructions

### Option 1: Bundler

Add the following to bundler's `Gemfile`.

```ruby
gem 'puts_debuggerer', '~> 0.10.2'
```

This is the recommended way for [Rails](rubyonrails.org) apps. Optionally, you may create an initializer under `config/initializers` named `puts_debuggerer_options.rb` to enable further customizations as per the [Options](#options) section below.

### Option 2: Manual

Or manually install and require library.

```bash
gem install puts_debuggerer -v0.10.2
```

```ruby
require 'puts_debuggerer'
```

Or the shorter form (often helpful to quickly troubleshoot an app):

```ruby
require 'pd'
```


### Awesome Print

[puts_debuggerer](https://rubygems.org/gems/puts_debuggerer) comes with [awesome_print](https://github.com/awesome-print/awesome_print).

It is the default `PutsDebuggerer.print_engine`

Still, if you do not need it, you may disable by setting `PutsDebuggerer.print_engine` to another value. Example:

```ruby
PutsDebuggerer.print_engine = :puts
```

If you also avoid requiring 'awesome_print', PutsDebuggerer won't require it either if it sees that you have a different `print_engine`

You may also avoid requiring in Bundler `Gemfile` with `require: false`:

```ruby
gem "awesome_print", require: false
gem "puts_debuggerer"
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

#### `pd_inspect` kernel method

You may want to just return the string produced by the `pd` method without printing it.

In that case, you may use the `pd` alternative to `object.inspect`:
- `object.pd_inspect` 
- `obj.pdi` (shorter alias)

This returns the `pd` formatted string without printing to the terminal or log files.

#### Ruby Logger and Logging::Logger 

Ruby Logger and Logging::Logger (from [logging gem](https://github.com/TwP/logging)) are supported as [printers](#putsdebuggererprinter) (learn more under [PutsDebuggerer#printer](#putsdebuggererprinter)). 

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
pd (x=1), header: true
```

Prints out:

```bash
********************************************************************************
[PD] /Users/User/example.rb:1
   > pd (x=1), header: true
  => "1"
```

Global Option Example:

```ruby
PutsDebuggerer.header = true
pd (x=1)
pd (x=2)
```

Prints out:

```bash
********************************************************************************
[PD] /Users/User/example.rb:2
   > pd (x=1)
  => "1"
********************************************************************************
[PD] /Users/User/example.rb:3
   > pd (x=2)
  => "2"
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
pd (x=1), footer: true
```

Prints out:

```bash
[PD] /Users/User/example.rb:1
   > pd (x=1), footer: true
  => "1"
********************************************************************************
```

Global Option Example:

```ruby
PutsDebuggerer.footer = true
pd (x=1)
pd (x=2)
```

Prints out:

```bash
[PD] /Users/User/example.rb:2
   > pd (x=1)
  => "1"
********************************************************************************
[PD] /Users/User/example.rb:3
   > pd (x=2)
  => "2"
********************************************************************************
```

#### `PutsDebuggerer.wrapper`
(default = `'*'*80`)

Wrapper to include at the top and bottom of every print out (both header and footer).
* Default value is `nil`
* Value `true` enables wrapper as `'*'*80`
* Value `false`, `nil`, or empty string disables wrapper
* Any other string value gets set as a custom wrapper

Example:

```ruby
pd (x=1), wrapper: true
```

Prints out:

```bash
********************************************************************************
[PD] /Users/User/example.rb:1
   > pd x=1, wrapper: true
  => "1"
********************************************************************************
```

Global Option Example:

```ruby
PutsDebuggerer.wrapper = true
pd (x=1)
pd (x=2)
```

Prints out:

```bash
********************************************************************************
[PD] /Users/User/example.rb:2
   > pd (x=1)
  => "1"
********************************************************************************
********************************************************************************
[PD] /Users/User/example.rb:3
   > pd (x=2)
  => "2"
********************************************************************************
```

#### `PutsDebuggerer.source_line_count`
(default = `1`)

Prints multiple source code lines as per count specified. Useful when a statement is broken down on multiple lines or when there is a need to get more context around the line printed. 

Example:

```ruby
pd (true ||
  false), source_line_count: 2
```

Prints out:

```
[PD] /Users/User/example.rb:1
   > pd (true ||
       false), source_line_count: 2
  => "true"
```

Example:

```ruby
PutsDebuggerer.source_line_count = 2 # setting via global option
pd (true ||
  false)
```

Prints out:

```
[PD] /Users/User/example.rb:2
   > pd (true ||
       false), source_line_count: 2
  => "true"
```

#### `PutsDebuggerer.printer`
(default = `:puts`)

Printer is a global method symbol, lambda expression, or logger to use in printing to the user.

Examples of a global method are `:puts` and `:print`.
An example of a lambda expression is `lambda {|output| Rails.logger.info(output)}`
Examples of a logger are a Ruby `Logger` instance or `Logging::Logger` instance

When a logger is supplied, it is automatically enhanced with a PutsDebuggerer formatter to use 
when calling logger methods outside of PutsDebuggerer (e.g. `logger.error('msg')` will use `pd`)

Printer may be set to `false` to avoid printing and only return the formatted string.
It is equivalent of just calling `.pd_inspect` (or alias `.pdi`) on the object

Defaults to `:puts`
In Rails, it defaults to:
```ruby
lambda do |output|
  puts output if Rails.env.test?
  Rails.logger.debug(output)
end
```

Example:

```ruby
# File Name: /Users/User/example.rb
PutsDebuggerer.printer = lambda {|output| Rails.logger.error(output)}
str = "Hello"
pd str
```

Prints out in the Rails app log as error lines:

```bash
[PD] /Users/User/example.rb:5
   > pd str
  => Hello
```

#### `PutsDebuggerer.print_engine`
(default = `:ap`)

Print engine is similar to `printer`, except it is focused on the scope of formatting
the data object being printed (excluding metadata such as file name, line number,
and expression, which are handled by the `printer`).
As such, it is also a global method symbol or lambda expression.
Examples of global methods are `:p`, `:ap`, and `:pp`.
An example of a lambda expression is `lambda {|object| puts object.to_a.join(" | ")}`

Defaults to [awesome_print](https://github.com/awesome-print/awesome_print).

Example:

```ruby
# File Name: /Users/User/example.rb
PutsDebuggerer.print_engine = :p
array = [1, [2, 3]]
pd array
```

Prints out:

```bash
[PD] /Users/User/example.rb:4
   > pd array
  => [1, [2, 3]]
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

Global Option Example:

```ruby
# File Name: /Users/User/sample_app/lib/sample.rb
PutsDebuggerer.caller = 3 # always print 3 lines only of the stack trace
pd (x=1)
pd (x=2)
```

Prints out:

```bash
[PD] /Users/User/sample_app/lib/sample.rb:2
    > pd (x=1)
   => "1"
     /Users/User/sample_app/lib/master_samples.rb:368:in \`block (3 levels) in <top (required)>\'
     /Users/User/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/irb/workspace.rb:87:in \`eval\'
     /Users/User/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/irb/workspace.rb:87:in \`evaluate\'
     /Users/User/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/irb/context.rb:381:in \`evaluate\'
[PD] /Users/User/sample_app/lib/sample.rb:3
    > pd (x=2)
   => "2"
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

### Bonus API

puts_debuggerer comes with the following bonus API methods:

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

## Compatibility

[puts_debuggerer](https://rubygems.org/gems/puts_debuggerer) is fully compatible with: 
- [Ruby](https://www.ruby-lang.org/en/)
- [JRuby](https://www.jruby.org/)
- IRB
- Rails Console.

### Opal Ruby

[puts_debuggerer](https://rubygems.org/gems/puts_debuggerer) provides partial-compatibility in [Opal Ruby](https://opalrb.com/) with everything working except:
- AwesomePrint (using the `:p` printer instead)
- Source code display

[puts_debuggerer](https://rubygems.org/gems/puts_debuggerer) renders clickable source file/line links in Opal Ruby that take you to the source code in the web browser.

Here is an example of `pd` output in Opal:

```
[PD] http://localhost:3000/assets/views/garderie_rainbow_daily_agenda/app_view.self-72626d75e0f68a619b1c8ad139535d799d45ab6c730d083820b790d71338e983.js?body=1:72:12
   > 
  => "body"
```

## Change Log

[CHANGELOG.md](CHANGELOG.md)

## TODO

[TODO.md](TODO)

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

[MIT](LICENSE.txt)

Copyright (c) 2017-2020 - Andy Maleh.
