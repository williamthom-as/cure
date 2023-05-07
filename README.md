# Cure

![run tests](https://github.com/williamthom-as/cure/actions/workflows/rspec.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/cure.svg)](https://badge.fury.io/rb/cure)

Cure is a versatile tool designed to handle a wide range of CSV transformations. While it may take 
some time to get familiar with its features, once you do, you'll find it capable of performing a wide range of tasks.

Cure enables you to extract, clean, transform, remove, anonymize, replace, and manipulate data in entire spreadsheets
or specific sections. It operates in memory by default and can be integrated into existing workflows or 
controlled via the CLI.

**Please note**: Cure is under active development, is poorly documented (at the moment) and will have frequent 
breaking changes. Use at your own risk!

Check out here for some real world [examples](docs/examples/examples.md).

## Use Cases

- Anonymize and transform personal data in a CSV to prepare it for a public demo environments.
- Extract specific parts of a CSV and discard the remaining data.
- Perform complex transformations on values according to specific rules.
- Unpack JSON values into individual columns per key.
- Process large files sequentially while retaining variable history.

## When not to use

Cure processes CSV files as a whole. Some of its features require a complete parse of the file to extract the necessary 
data before transforming it. 

These features include:

- Variable extraction (for example, extracting a value from A1 and adding it to each row).
- Non-zero indexed headers (for example, taking values from rows 4 to 10 and using row 2 as the source header row).
- Expanding JSON fields into columns (for example, if row 1 has values [{"a":1, "b":2}], and row 2 has [{"c":3}], each 
row needs columns A, B, C, but row 1 doesn't know that until row 2).

If you have large datasets of streamable CSV data, there are more efficient and performant tools available. However, 
Cure makes it possible to perform more aggressive transformations, which may require more memory usage. If you still 
want to use Cure to process large files, you can choose to persist the datastore to disk instead of in memory, which 
may have a slight impact on performance.

## Example

### In Code
Cure can be used as part of your existing application. It is configured using a DSL that can either be inline,
or as a file. Check out [here](docs/README.md) for more information, including examples.

```ruby
require "cure"

# Inline initialisation

cure = Cure.init do
  # Optional, used to select a part of a frame or allocate variables from single cells
  extract do
    named_range name: "section_1", at: "B2:G6", headers: "B2:B6"
    variable name: "new_field", location: "A16"
  end

  # Optional, used to add/remove/copy/rename/explode columns from frames.
  build do
    candidate(column: "new_column", named_range: "section_1") { add }
  end
  
  # Optional, used to transform values, each candidate can have multiple transforms.
  # If no match is found, if_no_match will fire.
  transform do
    candidate column: "new_column", named_range: "section_1" do
      with_translation { replace("regex", regex_cg: "^vol-(.*)").with("variable", name: "new_field") }
      with_translation { replace("split", "token": ":", "index": 4).with("placeholder", name: "key2") }
      if_no_match { replace("full").with("variable", name: "new_field") }
    end
  end

  # Required, define exporters to export modified frames.
  export do
    terminal named_range: "section_1", title: "Preview", limit_rows: 5
    csv named_range: "section_1", file: "/tmp/cure/section_1.csv"
  end
end

cure.process(:path, "location_to_file.csv")
```

## Installation

### Requirements

  - Ruby 2.6 or above
  - SQLite3

Install it yourself as:

    $ gem install cure

## Usage

### CLI
Cure requires a template and source CSV file to be provided.  The template file can be either JSON or YAML, and it must
contain all the instructions you wish to perform.

You can run the CLI using the following command:

    $ cure -t /file/path/to/template.json -s /file/path/to/source_file.csv

### Try it out

To quickly spin up a development environment, please use the Dockerfile provided. Run:

    $ docker build -t cure .
    $ docker run -it --rm cure bash

Please do not forget to mount any volumes which may have templates that you wish to use. Default templates are available too, found under `/app/templates`.

Once set up and connected to your container, run:

    $ cure -t template.rb -s /source_file.csv 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/williamthom-as/cure. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/cure/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cure project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cure/blob/master/CODE_OF_CONDUCT.md).
