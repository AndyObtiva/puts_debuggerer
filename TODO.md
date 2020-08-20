# TODO

Here are tasks considered for future versions. Once done, they are moved to the [Change Log](CHANGELOG.md)

## Next

### 0.9.0


### Version TBD

- Add print_stream option to specify alternatives to stdout like StringIO, syslog, etc...
- Add require 'pd' alternative to require 'puts_debuggerer'
- `return: false` option to return printed String instead of returning printed object
- Provide as logging device and/or formatter for Ruby logger API and/or logging gem
* fix issue with printing in rspec inside a Rails project without having to do extra configuration
* fix issue with erb support
- support sequences for run_at, such as print on odd/even numbers
* pry support: implement fallback in irb for when line number cannot be discovered (issue happens in pry, perhaps this just means support pry)
- Consider supporting syslog when available
