Source > Extract > Validate > Build > Query > Transform > **Export**

Export
=======

### About

Exporting is the final step, where you are given each row at the end of each previous step. You can have multiple 
exporters, that can each point to different named ranges, or the same.

A common pattern is to export the first 10 rows to terminal, and export the larger dataset to a CSV.

---

**When you should use this**: You have transformed your data, and you want to save the results.

See below an example configuration block:

### Example

```ruby
export do
  # Export to terminal window
  terminal title: "Exported", limit_rows: 5, named_range: "mysheet"
  
  # Export to a single CSV
  csv file_name: "mysheet", directory: "/tmp/cure", named_range: "mysheet"
  
  # Export to multiple CSVs each with 100 rows. 
  # These will be exported as 1_mysheet.csv, 2_mysheet.csv... n_mysheet.csv
  chunk_csv file_name_prefix: "mysheet", directory: "/tmp/cure", chunk_size: 100, named_range: "mysheet"
  
  # Yield out each row to a custom proc. This allows for the caller to do whatever they want
  # with the row. You could use this to make a API call to insert data to remote system.
  yield_row named_range: "mysheet", proc: proc { |row| puts row }
end
```
