[... go back to build contents](main.md)

## Add 

### What is it?

Add builder will add a new, empty column to the spreadsheet.

### Why would you need it?

As useless as a new empty column sounds, it can be used for a placeholder column to be used later. A common example
of this may be if you want to add a variable to each row.  For example, at the top of a spreadsheet, you may have a 
date, but you want to add that to each row.

### Full Configuration

```ruby
build do
  candidate(column: "new_column", named_range: "mysheet") { add options: { default_value: "-" } }
end
```
- `column`: represents the column name, mandatory.
- `named_range`: specifies the named range holding the column, if no named range has been set you can leave it blank.
  - `options`:
    - `value`: not mandatory, if provided will add to the initial row value. 

### Example

```ruby
build do
  candidate(column: "col_b") { add }
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
+-------+-------+
| col_a | col_b |
+-------+-------+
| a     |       |
+-------+-------+
```