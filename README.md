# Cure

![run tests](https://github.com/williamthom-as/cure/actions/workflows/rspec.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/cure.svg)](https://badge.fury.io/rb/cure)

Cure is a simple tool to **extract/clean/transform/remove/redact/anonymize** and **replace** information in a spreadsheet.
It operates purely in memory, and can be easily integrated into an existing work flow or controlled via CLI.

It has several key features:
- Operate on your data to build what you need. 
  - Files are taken through an `Extract -> Build -> Transform -> Export` pipeline.
- [Extract](docs/extract/main.md) parts of your file into named ranges to remove junk. 
- [Build](docs/builder/main.md) columns.
- [Transform](docs/transform/main.md) values:
  - Define either full or regex match groups replacements.
  - Choose from many strategies to replace anonymous data - random number sequences, GUIDs, placeholders, multipliers amongst many others.
  - **Existing generated values are stored and recalled** so once a replacement is defined, it is kept around for other columns to use.
    - For example, once a replacement **Account Number** is generated, any further use of that number sequence is other columns will be used, keeping data real(ish) and functional in a relational sense.
- [Export](docs/export/main.md) into one (or many) files, in a selection of chosen formats (CSV at the moment, coming soon with JSON, Parquet).

If you need help crafting templates with a visual tool, you can checkout [Cure UI](https://github.com/williamthom-as/cure-ui) (still under development). 

**Please note**: Cure is under active development, and will have frequent breaking changes. Use at your own risk!

## Use Cases

- Strip out and transform personal data from a CSV so that may be used for public demo.
- Extract specific parts of a CSV file and junk the rest.
- Doing complex transformations on values under specific rules.
- Explode JSON values into individual columns per key.

## Installation

Install it yourself as:

    $ gem install cure

## Usage

### CLI
Cure requires a template and source CSV file to be provided.  The template file can be either JSON or YAML, and it must
contain all the instructions you wish to perform.

Please see the [Getting Started](docs/examples/getting_started.md) article in the examples directory for more information.

You can run the CLI using the following command:

    $ cure -t /file/path/to/template.json -s /file/path/to/source_file.csv

### In Code
Cure can be used as part of your existing application. 

```ruby
# CSV file can either be path to file, File object or file contents
# Template can either be path to template, or Cure::Template object

require "cure"

transformed_csv = Cure::Main.new
                            .with_csv_file(:pathname, Pathname.new(source_file_loc))
                            .with_template(:pathname, Pathname.new(template_file_loc))
                            .init

result = main.run_export

# This will return a result object consisting of extracted/transformed headers and rows.
```

### Getting started *quickly*

To quickly spin up a development environment, please use the Dockerfile provided. Run:

    $ docker build -t cure .
    $ docker run -it --rm cure bash

Please do not forget to mount any volumes which may have templates that you wish to use. Default templates are available too, found under `/app/templates`.

Once set up and connected to your container, run:

    $ cure -t /file/path/to/template.json -s /file/path/to/source_file.csv -o /my/output/folder

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/williamthom-as/cure. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/cure/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cure project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cure/blob/master/CODE_OF_CONDUCT.md).
