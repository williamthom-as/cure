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

- Strip out personal data from a CSV that may be used for public demo.

## Usage

Cure requires two things, a **template** (or rules) file. This is a descriptive file that provides the translations required on each column.  
A candidate column entry provides the translations to be run on each column.

Please see example below.
```json
    {
      "column" : "identity/LineItemId",
      "translations" : [{
        "strategy" : {
          "name": "full",
          "options" : {}
        },
        "generator" : {
          "name" : "character",
          "options" : {
            "length" : 52,
            "types" : [
              "lowercase", "number", "uppercase"
            ]
          }
        }
      }]
    }
```

A **translation** is made up of a strategy and generator.

**Strategies** are the means of selecting the *value* to change. You may choose from:
  - **Full replacement**: replaces the full entry. 
  - **Regex replacement**: can replace either the match group (partial), or full record *if* there is a match.
  - **Includes replacement**: can replace either the matched substring, or full record *if* there is a match.
  - **StartWith replacement**: can replace either the starts with substring, or full record *if* there is a match.
  - **EndWith replacement**: can replace either the end with substring, or full record *if* there is a match.

**Generators** are the way a replacement value is generated. You may choose from: 
  - Random number generator
  - Random Hex numbers
  - Random character strings
  - Placeholder lookups
  - Redaction strings
  - Removal (empty string)

## Example

```json
    {
      "column" : "identity/ResourceId",
      "translations" : [{
        "strategy" : {
          "name": "full",
          "options" : {}
        },
        "generator" : {
          "name" : "character",
          "options" : {
            "length" : 10,
            "types" : [
              "lowercase", "number"
            ]
          }
        }
      }]
    }
```

The above example would translate a source value from column **identity/ResourceId** as follows:
    
    i-ae44e104ef1 => ddsf78ds56 

    # A full replacement, with a random generated 10 character string 
    # made up of lowercase letters and numbers

You can see more of these examples in the Examples folder.

## Installation

Install it yourself as:

    $ gem install cure

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
