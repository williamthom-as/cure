Extract > **Build** > Transform > Export 

Build
=======

### About

The build step immediately follows the **extract** step, and operates at a column level on the spreadsheet. It provides
an interface to manipulation that you may wish to occur across all columns.  Individual build steps are called
candidates, and *multiple steps can be performed on a single column* if desired.  

---

**When you should use this**: You have a spreadsheet that requires changes to the column structure of the data. This 
may be as trivial as adding or removing a column, or *exploding* a JSON object (Key => Val) into individual columns.

See below an example configuration block:

```yaml
 build:
   candidates:
     - column: "column_name"
       named_range: "default"
       action:
        ...
```

- `column`: represents the column name, mandatory.
- `named_range`: specifies the named range holding the column, if no named range has been set you can leave it blank.
- `action`: represents the action that will be taken on the data, select from the list below for more information.

### Components

There are four different types of operations you can perform in this step; 
- [add](add.md)
- [remove](remove.md)
- [copy](copy.md)
- [explode](explode.md)