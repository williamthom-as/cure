[... go back to build contents](main.md)

## Copy 

### What is it?

Copy builder will copy an entire column from the spreadsheet.

### Why would you need it?

Copy a column from the spreadsheet, useful if you want to transform or manipulate the column in the transform stage.

### Full Configuration

```ruby
build do
  candidate(column: "col_b", named_range: "_default") { copy options: { to_column: "col_b_copy" } }
end
```
- `column`: represents the column name, mandatory.
- `named_range`: specifies the named range holding the column, if no named range has been set you can leave it blank.
  - `options`:
    - `to_column`: column will be renamed to this value if set, otherwise will default to <column>_copy.
    
### Example

```ruby
build do
  candidate(column: "col_a") { copy options: { to_column: "col_a_copy" } }
end
```

Original input:
```
+-------+
| col_a |
+-------+
| a     |
+-------+
```
changes to:
```
+-------+------------+
| col_a | col_a_copy |
+-------+------------+
| a     | a          |
+-------+------------+
```
