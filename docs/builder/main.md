Extract > **Build** > Transform > Export 

Build
=======

### About

The build step immediately follows the **extract** step, and operates at a column level on the spreadsheet. It provides
an interface to manipulation that you may wish to occur across all columns.  Individual build steps are called
candidates, and *multiple steps can be performed on a single column* if desired.  

---

**When you should use this**: You have a spreadsheet that requires changes to the column structure of the data. This 
may be as trivial as adding or removing a column, or *exploding* a JSON object (Key => Val) into individual columns.

See below an example configuration block:

```ruby
build do
  # White/Blacklist - do not need to provide column into candidate
  candidate do
    blacklist options: { columns: %w[col_a col_b] }
    whitelist options: { columns: %w[col_c col_d] }
  end

  # Simple addition of new column
  candidate(column: "full_name") { add options: { default_value: "ABC" } }
  # Simple renaming of existing column
  candidate(column: "Tags") { rename options: { new_name: "test" } }
end
```

- `column`: represents the column name, mandatory.
- `named_range`: specifies the named range holding the column, if no named range has been set you can leave it blank.

### Components

There are four different types of operations you can perform in this step; 
- [add](add.md)
- [remove](remove.md)
- [copy](copy.md)
- [black_white_list](black_white_list.md)