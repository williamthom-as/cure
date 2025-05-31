# Cure

![run tests](https://github.com/williamthom-as/cure/actions/workflows/rspec.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/cure.svg)](https://badge.fury.io/rb/cure)

### What does it do?

- Extract data from one or more CSV files.
- Clean, transform, query and export CSVs (or other formats).
- Manipulate and join or separate CSVs using SQL expressions.
- Automate these actions using low code templates.
- Query and extract insights into a standalone self-hosted BI dashboards.
- Use version control to maintain and share your project with others.

-----

Cure provides a low-code solution for handling a wide range of tasks for importing, validating and manipulating one or
more CSV files. Unlike other tools, Cure doesn't assume standard CSV formatting and is designed to handle a wide range of 
challenging scenarios.

The library provides optional hooks for each data processing pipeline phase in:

`Sources -> Extract -> Validate -> Build -> Query -> Transform -> Export`

See below for a simple example that loads customer data from a single CSV, redacts the email records, and stores the 
result in a new CSV.

```ruby
require "cure"

handler = Cure.init do
  sources { csv :pathname, Pathname.new("customer_data.csv") }
  
  extract { named_range at: "D2:G8" }

  transform do
    candidate column: "email" do
      with_translation { replace("split", token: "@", index: 0).with("redact") }
      with_translation { replace("split", token: "@", index: -1).with("redact") }
    end
  end

  export { csv file_name: "cust_transformed", directory: "/tmp/cure" }
end

handler.run_export

# Input (customer_data.csv):                Output (cust_transformed.csv):
#                                           
# | id | email                  |           | id | email                  |     
# |----|------------------------|    =>     |----|------------------------|     
# | 1  | john.smith@gmail.com   |           | 1  | xxxxxxxxxx@xxxxx.com   |     
# | 2  | lean.davis@outlook.com |           | 2  | xxxxxxxxxx@xxxxxxx.com |     

```

Click this link to view the [documentation](docs/README.md), see a real world [example](http://www.williamthom.as/csv/ruby/2023/04/06/transforming-csvs-with-cure.html), 
or see a longer list of [features](docs/about.md).

## Installation

### Requirements

- Ruby 3.0 or above
- SQLite3

Install it yourself as:

    $ gem install cure

## Usage

### CLI

You can start a new Cure project using CLI using the following command:

    $ cure new [name]

This will create a directory to house templates, input and output directories amongst others.

To perform a one-off run, you can do it manually via the CLI using the following command:

    $ cure run -t template.rb -s source_file.csv 

You can view help with the following command:

    $ cure help

### Try it out

To quickly spin up a development environment, please use the Dockerfile provided. Run:

    $ docker build -t cure .
    $ docker run -it --rm cure bash

Please do not forget to mount any volumes which may have templates that you wish to use. Default templates are available too, found under `/app/templates`.

Once set up and connected to your container, run:

    $ cure run -t template.rb -s source_file.csv 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/williamthom-as/cure. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/cure/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cure project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cure/blob/master/CODE_OF_CONDUCT.md).
