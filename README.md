# puts_debuggerer v0.1.0
[![Gem Version](https://badge.fury.io/rb/puts_debuggerer.svg)](http://badge.fury.io/rb/puts_debuggerer)
[![Build Status](https://travis-ci.org/AndyObtiva/puts_debuggerer.svg?branch=master)](https://travis-ci.org/AndyObtiva/puts_debuggerer)

Ruby tools for improved puts debugging, automatically displaying bonus useful information such as line number and source code.

Partially inspired by this blog post:
https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html
(Credit to Tenderlove.)

# Instructions

### Bundler

Add the following to bundler's `Gemfile`.

```ruby
gem 'puts_debuggerer', '~> 0.1.0'
```

### Manual

Or manually install and require library.

```bash
gem install puts_debuggerer
```

```ruby
require 'puts_debuggerer'
```

### Usage

Simple invoke global `pd` method anywhere you'd like to see line number and source code with output.
If the argument is a pure string, the print out is simplified by not showing duplicate source.

Quickly find printed lines by running a find (e.g. CTRL+F) for "pd " or ".inspect => "

Happy puts debugging!

Example Code:

```ruby
bug = 'beattle'
pd "Show me the source of the bug: #{bug}"
pd 'What line number am I?'
```

Example Printout:

```bash
pd 2: "Show me the source of the bug: #{bug}".inspect => "Show me the source of the bug: beattle"
pd 3: "What line number am I?"
```

## Contributing to puts_debuggerer

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2017 Andy Maleh. See LICENSE.txt for
further details.
