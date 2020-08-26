# TODO

Here are tasks considered for future versions. Once done, they are moved to the [Change Log](CHANGELOG.md)

## Next

### 0.10.0

- Refactor internals to avoid global method pollution

### Version TBD

- fix issue with printing in rspec inside a Rails project without having to do extra configuration
- fix issue with erb support
- pry support: implement fallback in irb for when line number cannot be discovered (issue happens in pry, perhaps this just means support pry)
- Consider the idea of customizing print stream (e.g. stderr instead of stdout). Currently possible through setting `printer`
