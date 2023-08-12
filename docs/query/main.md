Source > Extract > Validate > Build > **Query** > Transform > Export

Query
=======

### About

The query step allows you to customise what data is returned from the extract step.

If this step is not provided, `SELECT * FROM _default` is run. Whatever you put in the SELECT (aliases etc) will
be returned to you for transforming.

---

**When you should use this**: You want to harness the full power of SQL to return a more tailored response. 

See below an example configuration block:

### Example

```ruby
query do
  with named_range: "data_log", query: <<-SQL
    SELECT
      *
    FROM 
      data_log
    WHERE
      Equipment = 'Raw'
    AND
      (Division = 'O' OR Division = 'Open')
    AND
      Event = 'SBD'
    AND
      ParentFederation = 'IPF'
    AND
      Sex = 'F'
    AND
      strftime('%Y', Date) > '2014'
    ORDER BY Date DESC
  SQL
end

```

