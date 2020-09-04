# TODO

Here are tasks considered for future versions. Once done, they are moved to the [Change Log](CHANGELOG.md)

## Next

### 0.10.1

- Fix pd_inspect and pdi in IRB as they seem broken when used in Glimmer GIRB for example
- Provide option to set a logger as printer without hooking formatter unto logger
- Provide an option to control what log level is used when printing to logger
- Look into [Maintainability](https://codeclimate.com/github/AndyObtiva/puts_debuggerer/issues) issues
- Special treatment for string objects since AwesomePrint seems does not print multiline

### Version TBD

- Add method_name to what shows up as part of pd call
- Support auto puts_debuggering of all method names and arguments upon invokation
- Refactor internals to avoid global method pollution
- fix issue with printing in rspec inside a Rails project without having to do extra configuration
- fix issue with erb support
- pry support: implement fallback in irb for when line number cannot be discovered (issue happens in pry, perhaps this just means support pry)
- Consider the idea of customizing print stream (e.g. stderr instead of stdout). Currently possible through setting `printer`
- Highlight the pd being printed if multiple pds exist in the same line (perhaps by calling .red on its string reusing that from ap)
