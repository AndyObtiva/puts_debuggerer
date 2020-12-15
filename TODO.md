# TODO

Here are tasks considered for future versions. Once done, they are moved to the [Change Log](CHANGELOG.md)

## Next

- Add the ability to disable all pd statement with a switch for convenience when going back and forth with printing/not-printing (e.g. troubleshooting while testing performance)
- Have `caller` printing in Glimmer DSL for Opal print one statement per line
- Support header: 30 to customize the length of the header (and do the same for footer and wrapper)
- Support header: '#' to customize the character of the header (and do the same for footer and wrapper)
- Consider making header use >>> and footer <<< instead of * for better findability.
- Provide option to set a logger as printer without hooking formatter unto logger
- Provide an option to control what log level is used when printing to logger
- Look into [Maintainability](https://codeclimate.com/github/AndyObtiva/puts_debuggerer/issues) issues
- Special treatment for string objects since AwesomePrint seems does not print multiline
- Add a hyperlink to file showing up (linking to GitHub repo using something like tty-markdown)

## Version TBD

- Add method_name to what shows up as part of pd call
- Add performance monitoring support
- Support auto puts_debuggering of all method names and arguments upon invokation
- Refactor internals to avoid global method pollution
- fix issue with printing in rspec inside a Rails project without having to do extra configuration
- fix issue with erb support
- Consider the idea of customizing print stream (e.g. stderr instead of stdout). Currently possible through setting `printer`
- Highlight the pd being printed if multiple pds exist in the same line (perhaps by calling .red on its string reusing that from ap)
- Have pd support running from JAR files in JRuby
