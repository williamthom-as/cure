Cure
===

Cure is a simple tool to **remove/redact/anonymize** and **replace** private information in a spreadsheet.
It has been written to anonymize private cloud billing data for use in public demo environments.

It has several key features:
- Define either full or regex match groups replacements.
- Choose from many strategies to replace anonymous data - random number sequences, GUIDs, placeholders, multipliers amongst many others.
- **Existing generated values are stored and recalled** so once a replacement is defined, it is kept around for other columns to use.
  - For example, once a replacement **Account Number** is generated, any further use of that number sequence is other columns will be used, keeping data real(ish) and functional in a relational sense.

## Use Cases

- Strip out personal data from a spreadsheet that may be used for public demo.

## Usage

TODO

## Example

TODO

## Installation

TODO

## Getting started

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/williamthom-as/cure. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/cure/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cure project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cure/blob/master/CODE_OF_CONDUCT.md).
