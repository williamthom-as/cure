**Metadata** > Source > Extract > Validate > Build > Query > Transform > Export

Metadata
=======

### About

The metadata step will not affect the process, but allows you to document things you might want to in the template.

---

**When you should use this**: You want to record some information - version, author, date. 

See below an example configuration block:

### Example

```ruby
metadata do
  name "My Dataset"
  version 1
  comments "A useless comment"
  additional data: {
    created_date: "2023-01-01 00:00",
    author: "william"
  }
end
```

