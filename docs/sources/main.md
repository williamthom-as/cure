**Sources** > Extract > Validate > Build > **Query** > Transform > Export

Sources
=======

### About

The sources step allows you to define the files that will be extracted. You can supply it in the template,
or you can provide it when you are initializing `Cure::Launcher`.

As Cure templates are just Ruby, you can define the files dynamically, and provide them to the template DSL.

---

**When you should use this**: You want to load a CSV file, but you don't want to do it at initialize.

See below an example configuration block:

### Example

```ruby
sources do
  csv :pathname, Pathname.new("loc/to/my/file_1.csv"), ref_name: "file_1"
  csv :pathname, Pathname.new("loc/to/my/file_2.csv"), ref_name: "file_2"
end
```

or using Ruby (this is a contrived example)

```ruby
[Pathname.new("loc/to/my/file_1.csv"), Pathname.new("loc/to/my/file_2.csv")].each_with_index do |file_path, idx|
  sources do
    csv :pathname, file_path, ref_name: "file_#{idx}"
  end
end
```