[... go back to build contents](main.md)

## Remove 

### What is it?

Remove builder will remove an entire column from the spreadsheet.

### Why would you need it?

Removes a column from the spreadsheet, useful if you want to remove entire columns from the output.

### Full Configuration

```yaml
build:
  candidates:
    - column: "column_name"
      named_range: "default"
      action:
        type: "remove"
```
- 
- `column`: represents the column name, mandatory.
- `named_range`: specifies the named range holding the column, if no named range has been set you can leave it blank.
- `action`: represents the action that will be taken on the data.
  - `type`: specifies the type of action, in this instance is remove.

### Example

```yaml
build:
  candidates:
    - column: "col_b" 
      action:
        type: "remove"
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
