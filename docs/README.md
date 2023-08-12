# Cure

### Cure Documentation

- [Metadata](metadata/main.md)
- [Sources](sources/main.md)
- [Extract](extract/main.md)
- [Validate](validate/main.md)
- [Build](builder/main.md)
- [Query](query/main.md)
- [Transform](transform/main.md)
- [Export](export/main.md) 

Cure has several key features:
- A clean DSL to describe the operations that you want to do. This can be defined in code, or loaded from a file that
  could be version controlled.
- Operate on your data to build what you need.
    - Files are taken through an `Source -> Extract -> Validate -> Build -> Query -> Transform -> Export` pipeline.  
    - Each of these steps is optional.
- [Metadata](metadata/main.md) allows you to add some comments to your template. Will not impact functionality.
- [Sources](sources/main.md) are where you define the file(s) that you wish to operate on.
- [Extract](extract/main.md) parts of your file into named ranges to remove junk.
- [Validate](validate/main.md) that data fits your expectations.
- [Build](builder/main.md) (add, remove, rename, copy, explode) columns.
- [Query](query/main.md) your extracted data using SQLite to further control your desired data.
- [Transform](transform/main.md) values:
    - Define either full, split, partials or regex match groups replacements.
    - Choose from many strategies to replace data - random number sequences, GUIDs, placeholders, multipliers amongst many others.
    - **Existing generated values are stored and recalled** so once a replacement is defined, it is kept around for other columns to use.
        - For example, once a replacement **Account Number** is generated, any further use of that number sequence is other columns will be used, keeping data real(ish) and functional in a relational sense.
- [Export](export/main.md) into one (or many) files, in a selection of chosen formats, CSV (single or chunked files), or create a custom proc to do whatever you want.

Please see the [Examples](examples/examples.md) article in the examples directory for more information.