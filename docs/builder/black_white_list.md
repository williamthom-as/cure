[... go back to build contents](main.md)

## Black/White List 

### What is it?

These builders operate at a sheet level, bulk changing the columns provided.
- Blacklist will bulk remove any columns **in** the list provided.
- Whitelist will bulk remove any columns **not in** the list provided. 

### Why would you need it?

If you have a large spreadsheet that you want to control the presence or removal of multiple columns,
the quickest way to do so is via this option.

### Full Configuration

```ruby
candidate(named_range: "mysheet") do
  blacklist options: { columns: %w[col_a col_b] }
  whitelist options: { columns: %w[col_c col_d] }
end
```

- `named_range`: specifies the named range holding the column, if no named range has been set you can leave it blank.
  - `options`:
    - `columns`: mandatory, will perform filtering on these options. 

### Example

## Blacklist

```ruby
candidate(named_range: "mysheet") do
  blacklist options: { columns: %w[col_a col_b] }
end
```

Original input: 
```
+-------+-------+-------+
| col_a | col_b | col_c |
+-------+-------+-------+
| a     | b     | c     |
+-------+-------+-------+
```

changes to: 

```
+-------+
| col_c |
+-------+
| c     |
+-------+
```

## Whitelist

```ruby
candidate(named_range: "mysheet") do
  whitelist options: { columns: %w[col_a col_b] }
end
```

Original input:
```
+-------+-------+-------+
| col_a | col_b | col_c |
+-------+-------+-------+
| a     | b     | c     |
+-------+-------+-------+
```

changes to:

```
+-------+-------+
| col_a | col_b |
+-------+-------+
| a     | b     |
+-------+-------+
```