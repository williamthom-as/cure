[... go back to build contents](main.md)

## Remove 

### What is it?

Remove builder will remove an entire column from the spreadsheet.

### Why would you need it?

Removes a column from the spreadsheet, useful if you want to remove entire columns from the output.

### Full Configuration

```ruby
build do
  candidate(column: "remove_this", named_range: "mysheet") { remove }
end
```
- `column`: represents the column name, mandatory.
- `named_range`: specifies the named range holding the column, if no named range has been set you can leave it blank.

### Example

```ruby
build do
  candidate(column: "col_b") { remove }
end
```

Original input:
```
+-------+-------+
| col_a | col_b |
+-------+-------+
| a     | b     |
+-------+-------+
```
changes to: 
```
+-------+
| col_a |
+-------+
| a     |
+-------+
```
