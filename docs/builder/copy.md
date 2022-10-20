[... go back to build contents](main.md)

## Copy 

### What is it?

Copy builder will copy an entire column from the spreadsheet.

### Why would you need it?

Copy a column from the spreadsheet, useful if you want to transform or manipulate the column in the transform stage.

### Full Configuration

```yaml
build:
  candidates:
    - column: "col_b"
      named_range: "default"
      action:
        type: "copy"
        options:
          copy_column: "col_b_copy"
```
- 
- `column`: represents the column name that data will be copied from, mandatory.
- `named_range`: specifies the named range holding the column, if no named range has been set you can leave it blank.
- `action`: represents the action that will be taken on the data.
  - `type`: specifies the type of action, in this instance is remove.
  - `options`:
    - `copy_column`: column will be renamed to this value if set, otherwise will default to <column>_copy.
    
### Example

```yaml
build:
  candidates:
    - column: "col_a" 
      action:
        type: "copy"
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
