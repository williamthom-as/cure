# Cure

### Cure Documentation

- [Extract](extract/main.md)
- [Build](builder/main.md) 
- [Transform](transform/main.md)
- [Export](export/main.md) 

Cure has several key features:
- A clean DSL to describe the operations that you want to do. This can be defined in code, or loaded from a file that
  could be version controlled.
- Operate on your data to build what you need.
    - Files are taken through an `Extract -> Build -> Transform -> Export` pipeline.  Each of these steps is optional.
- [Extract](extract/main.md) parts of your file into named ranges to remove junk.
- [Build](builder/main.md) (add, remove, rename, copy, explode) columns.
- [Transform](transform/main.md) values:
    - Define either full, split, partials or regex match groups replacements.
    - Choose from many strategies to replace data - random number sequences, GUIDs, placeholders, multipliers amongst many others.
    - **Existing generated values are stored and recalled** so once a replacement is defined, it is kept around for other columns to use.
        - For example, once a replacement **Account Number** is generated, any further use of that number sequence is other columns will be used, keeping data real(ish) and functional in a relational sense.
- [Export](export/main.md) into one (or many) files, in a selection of chosen formats (CSV at the moment, coming soon with JSON, Parquet).

Please see the [Examples](examples/examples.md) article in the examples directory for more information.