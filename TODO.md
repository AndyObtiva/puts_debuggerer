# TODO

Here are tasks considered for future versions. Once done, they are moved to the [Change Log](CHANGELOG.md)

## Next

### 0.10.0

- Add require 'pd' alternative to require 'puts_debuggerer'
- `return: false` option to return printed String instead of returning printed object
- Support `printer` as a Logger object or Logging::Logger (from "logging" gem). Perhaps discover via ducktyping.
- Provide as logging device and/or formatter for Ruby logger API and/or logging gem
- Refactor internals to avoid global method pollution
- Rename `print_engine` option to `formatter` to avoid confusion with `printer`

### Version TBD

* fix issue with printing in rspec inside a Rails project without having to do extra configuration
* fix issue with erb support
* pry support: implement fallback in irb for when line number cannot be discovered (issue happens in pry, perhaps this just means support pry)
