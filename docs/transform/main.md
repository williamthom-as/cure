Extract > Build > **Transform** > Export

Transform
=======

### About

The transform step is the arguably the most powerful step in the chain.  It is used when you want to *change* a value.
The process can be undertaken in multiple steps, performing transforms as you go. It is quite sophisticated, and does
not require homologous data for each value.

**When you should use this**: You have a value in a row, and you wish to change it.  

Transform is made up of many translations.  There are two main parts that make up a translations step, the 
**strategy** and the **generator** which are defined on a specific column.

**Strategy** is the means in which a value will be transformed. It is responsible for how and what part of the value 
will be transformed. The strategy will first look to extract the value that you wish to transform.  This can either
be simple, like a full replacement, or complex using regex.  Once it has the value extracted, it will attempt to find
any previously translated mapping before running it through the generator step.

**Generator** is the process of creating that transformed value.  It could be as simple as replace all characters with
the character "x", fill it with Faker data, set it to a random guid, modify the date format, inject a value from 
elsewhere on the spreadsheet (see [Build](../builder/main.md)).  

Once this value has been generated, it is stored against the existing value so any other translation will get the same.
This is particularly useful if you want to keep data integrity. For example, if you had two columns, one was `account
number`, and the other was `reference_id` (which was constructed by the format `account_number/identifier`).  Once you 
had set a replacement value for the account number (`abcde => defgh`), you wouldn't want a different value for the 
account number part of the `reference_id` column. 

```
+----------------+--------------+
| account_number | reference_id |
+----------------+--------------+
| abcde          | abcde/123456 |
+----------------+--------------+
```
changes to
```
+----------------+--------------+
| account_number | reference_id |
+----------------+--------------+
| defgh          | defgh/123456 |
+----------------+--------------+
```

---



See below an example configuration block:

### Example

