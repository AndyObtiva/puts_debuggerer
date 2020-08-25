# Change Log

## 0.9.0

- Provide partial support for Opal Ruby (missing display of file name, line number, and source code)
- `source_line_count` option
- `wraper` option for including both `header` and `footer`
- Special handling of exceptions (prints using full_message)
- Change :ap printer default to :p when unavailable
- Support varargs printing (example: `pd arg1, arg2, arg3`)
- Display `run_at` run number in printout
- Support `require 'pd`' as a shorter alternative to `require 'puts_debuggerer'`
- Support `printer` as a Logger object or Logging::Logger (from "logging" gem). Basically any object that responds to :debug method.
- Support `printer: false` option to return rendered String instead of printing and returning object

## 0.8.2

- require 'stringio' for projects that don't require automatically via other gems

## 0.8.1

- `printer` option support for Rails test environment

## 0.8.0

- `printer` option support

## 0.7.1

- default print engine to :ap (AwesomePrint)

## 0.7.0

- `run_at` option, global and piecemeal.

## 0.6.1

- updated README and broke apart specs

## 0.6.0

- unofficial erb support, returning evaluated object/expression, removed static syntax support (replaced with header support)

## 0.5.1

- support for print engine lambdas and smart defaults for leveraging Rails and AwesomePrint debuggers in Rails

## 0.5.0

- custom formatter, caller backtrace, per-puts piecemeal options, and multi-line support

## 0.4.0

- custom print engine (e.g. ap), custom announcer, and IRB support

## 0.3.0

- header/footer support, multi-line printout, improved format

## 0.2.0

- App path exclusion support, Rails root support, improved format

## 0.1.0

- File/line/expression print out
