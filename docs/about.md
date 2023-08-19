# Cure

Cure is a versatile tool designed to handle a wide range of tasks for importing or manipulating CSV data.
It may take time to get familiar with all the features, but once you do, it is capable of performing a wide
range of tasks.

Cure can be used as an end-to-end CSV importing tool, or for when you just want to validate, extract, merge,
clean, transform, remove, anonymize, replace, or manipulate tabular data. It operates in memory by default and
can be integrated into existing workflows or controlled via the CLI.

## Use Cases

Other CSV utils or importers often make assumptions that CSV data is nicely formatted tabular data. However, in the
real world you may get files don't follow a standard [header,row 1,row 2,row n] format. With Cure, you can load
specific parts of a file, or join multiple files together and treat them as one. See this
[blog post](http://www.williamthom.as/csv/ruby/2023/04/06/transforming-csvs-with-cure.html) for a detailed example.

Cure can be used for simple tasks like:
- Import data from a spreadsheet into a database.
- Split one CSV file into multiple files based on a filter (ex. M/F data in a single file into one M file and one F file).
- Change one 10,000 line CSV file into 10 1,000 line files.
- Extract specific parts of a CSV and discard the remaining data.
- Validate a CSV has the expected data against a spec.
- Fix data mistakes.

... and more complex ones like:
- Anonymize and transform personal data in a CSV to prepare it for a public demo environments.
- Perform complex transformations on values according to specific rules.
- Unpack JSON values into individual columns per key.
- Process large files sequentially while retaining variable history.
- Merge two or more CSV files (or parts thereof) together.

### In Code
Cure can be used as part of your existing application. It is configured using a DSL that can either be inline,
or as a file. Check out [docs](docs/README.md) for more information.

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

## How it works

The library provides designated hooks for each distinct phase in the data processing pipeline

`Extract -> Validate -> Build -> Query -> Transform -> Export`

You can choose to opt in to as many or as few stages as needed, no steps are mandatory.

Cure operates by extracting complete CSV files or specific portions of them into user defined named ranges (one or more
cells of tabular data), which are subsequently inserted into SQLite tables. This allows for the ability to join or
manipulate rows with SQL, *if you need it*. With data segmented into separate named ranges, multiple transforms and
exports can be performed in a single pass.

## Examples

### Chunk CSV files

This is a simple example that takes a sheet and exports it into multiple sheets of 10,000 rows max.

```ruby
require "cure"

handler = Cure.init do
  export do
    chunk_csv file_name_prefix: "my_sheet", directory: "/tmp/cure", chunk_size: 10_000
  end
end

handler.process(:path, "path/to/my_sheet.csv")
```

### Filter single file into multiple

This example takes in a sheet of male and female data and exports it into two files based on gender.

```ruby
require "cure"

handler = Cure.init do
  extract do
    named_range name: "male", at: -1
    named_range name: "female", at: -1
  end

  query do
    with named_range: "female", query: <<-SQL
      SELECT
        *
      FROM female
      WHERE
        Sex = 'F' AND strftime('%Y', Date) > '2014'
      ORDER BY Date DESC
    SQL

    with named_range: "male", query: <<-SQL
      SELECT
        *
      FROM male
      WHERE
        Sex = 'M' AND strftime('%Y', Date) > '2014'
      ORDER BY Date DESC
    SQL
  end

  export do
    csv file_name: "male", directory: "/tmp/cure", named_range: "male"
    csv file_name: "female", directory: "/tmp/cure", named_range: "female"
  end
end

handler.process(:path, "path/to/my_sheet.csv")
```

### Validate data

This example validates that a sheet has valid columns. It will throw an error if it isn't valid.

```ruby
require "cure"

handler = Cure.init do
  validate do
    candidate column: "rating", options: { fail_on_error: true } do
      with_rule :not_null
      with_rule :length, { min: 0, max: 5 }
    end

    candidate column: "phone_number", options: { fail_on_error: true } do
      with_rule :custom, { proc: proc { |val| val =~ /^04\d{8}$/ } }
    end
  end
end

handler.process(:path, "path/to/my_sheet.csv")
```

### Transform data

This example anonymizes private data found in a cloud invoice. Note that when the existing account number is found
in any column, it is replaced with the same value, maintaining referential integrity whilst being anonymized.

You can see the [before](spec/cure/e2e/input/aws_billing_input.csv) and [after](spec/cure/e2e/output/aws_billing_output.csv) CSVs
made from this template by clicking on the links.

```ruby
require "cure"

handler = Cure.init do
  build do
    candidate do
      whitelist options: {
        columns: %w[
          bill/BillingEntity
          bill/PayerAccountId
          bill/BillingPeriodStartDate
          bill/BillingPeriodEndDate
          lineItem/UsageAccountId
          lineItem/LineItemType
          lineItem/UsageStartDate
          lineItem/UsageEndDate
          lineItem/UsageType
          lineItem/ResourceId
          lineItem/ProductCode
          lineItem/UsageAmount
          lineItem/CurrencyCode
        ]
      }
    end
  end

  rot13_proc = proc { |source, _ctx|
    source.gsub(/[^a-zA-Z0-9]/, '').tr('A-Za-z', 'N-ZA-Mn-za-m')
  }

  transform do
    candidate column: "bill/PayerAccountId" do
      with_translation { replace("full").with("placeholder", name: :account_number) }
    end

    candidate column: "lineItem/UsageAccountId" do
      with_translation { replace("full").with("number", length: 10) }
    end

    candidate column: "lineItem/ResourceId", options: {ignore_empty: true} do
      # If there is a match (i-[my-group]), replace just the match group with a hex string of 10 length
      with_translation { replace("regex", regex_cg: "^i-(.*)").with("proc", execute: rot13_proc) }

      # If the string contains the account number, replace with the account_number placeholder.
      with_translation { replace("contain", match: "1234567890").with("placeholder", name: :account_number) }

      # If no match is found, replace the whole match with a prefix hidden_ along with a random 10 char hex string
      if_no_match { replace("full").with("proc", execute: rot13_proc) }
    end

    # Hardcoded values that we may wish to reference
    place_holders({account_number: 987_654_321})
  end

  export do
    terminal title: "Preview", limit_rows: 20
    csv file_name: "aws", directory: "/tmp/cure"
  end
end

handler.process(:path, "path/to/my_sheet.csv")
```