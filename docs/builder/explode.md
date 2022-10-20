[... go back to build contents](main.md)

## Explode

### What is it?

Explode takes a JSON string and will break it out into columns intelligently.

### Why would you need it?

If you have a JSON column and you wish to treat the values as an individual column per key.  This is popular in technical

### Full Configuration

```yaml
build:
  candidates:
    - column: "column_name"
      named_range: "default"
      action:
        type: "explode"
        options:
          filter:
            type: "whitelist|blacklist"
            values:
              - "example"
```
- 
- `column`: represents the column name, mandatory.
- `named_range`: specifies the named range holding the column, if no named range has been set you can leave it blank.
- `action`: represents the action that will be taken on the data
  - `type`: specifies the type of action, in this instance is explode
  - `options`:
    - `filter`: filters out the candidate columns, you can either use whitelist or blacklist.
    - `values`: contains the names of the columns that will be filtered with.


### Example

```yaml
build:
  candidates:
    - column: tags
      action:
        type: "explode"
```

Original input: 
```
+---------------------------------+
| tags                            |
+---------------------------------+
| {"type":"string","name":"abcd"} |
+---------------------------------+
| {"tier":"high"}                 | 
+---------------------------------+
```

changes to: 

```
+----------------------------------+--------+-------+------+
| tags                             | type   | name  | tier |
+----------------------------------+--------+-------+------+
| {"type":"string","name":"abcde"} | string | abcde |      |
| {"tier":"string"}                |        |       | high |
+----------------------------------+--------+-------+------+
```

**Note:** if you want to remove the original column (tags) you can do so with the [remove](remove.md) option.
