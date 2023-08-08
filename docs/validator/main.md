**Validator** > Build > Validate

Validator
=======

### About

The validator step checks that data in the spreadsheet is what is expected. This may involve checking
that data is of a certain format, and if it isn't, it can either fail or warn.

---

**When you should use this**: You have a spreadsheet that has data that needs to be in a certain format
before transforming or exporting. 

See below an example configuration block:

### Example

```ruby
validate do
  candidate column: "new_column", named_range: "section_1", options: { fail_on_error: false } do
    with_rule :not_null
    with_rule :length, { min: 0, max: 5 }
    with_rule :custom, { proc: Proc.new { |x| x.size >= 0 && x.size <= 5 } } # Proc version of above.
  end
end
```

Original input:
```
+------------+
| new_column | 
+------------+
| test       | <- Is valid
| test value | <- Is invalid (too long)
|            | <- Is invalid (null)
+------------+
```

As `fail_on_error` is set to false, this would warn that 2 values are invalid.

