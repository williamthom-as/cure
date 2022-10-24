**Extract** > Build > Transform > Export

Extract
=======

### About

The extract step is the first step that is undertaken on the spreadsheet.  If the spreadsheet is in the form you need,
(where headers and rows are in the right place), this step is not necessary.

There are two main processes that are available in this section; named ranges and variables.

**Named ranges** are a subset of your spreadsheets data.  In some situations, spreadsheets may have more than one section
of data that you are interested in. Using named ranges, and simple notation (eg. B2:G6), you can select as many ranges
as needed, and format them back together at the end.

**Variables** are a single row value that is extracted into a hash, and available at the transform stage. A common use
for this would be to extract a value from somewhere in the spreadsheet to allow it to be added to each row.

---

**When you should use this**: You have a spreadsheet that has more data than you need, or is in a format that is not 
strictly in a tabular format.  You may want to extract a part (or multiple parts) of the spreadsheet, and discard the
rest.

See below an example configuration block:

### Example

```yaml
extraction:
  named_ranges:
    - name: main
      section: B2:D4
    - name: secondary
      section: A2:D3 
  variables:
    - name: my_string
      type: single_field
      location: E5
```

Original input:
```
+----+----+----+----+----+
| a1 | b1 | c1 | d1 | e1 |
| a2 | b2 | c2 | d2 | e2 |
| a3 | b3 | c3 | d3 | e3 |
| a4 | b4 | c4 | d4 | e4 |
| a5 | b5 | c5 | d5 | e5 |
+----+----+----+----+----+
```
changes to: 
```
+--------------+
| main         |
+----+----+----+
| b2 | c2 | d2 |
| b3 | c3 | d3 |
| b4 | c4 | d4 |
+----+----+----+

+----+----+----+----+
| secondary         |
+----+----+----+----+
| a2 | b2 | c2 | d2 |
| a3 | b3 | c3 | d3 |
+----+----+----+----+

variables 
  - my_string => "e5" 
```

