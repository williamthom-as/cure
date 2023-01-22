## Examples

Below are some examples of how to use Cure to transform frames.

### AWS Cost and Usage Report Anonymization

Below a small subset of the Cost and Usage Report provided by Amazon that hold information that we want to transform.

Some thoughts;
- the **identity/LineItemId** column has seemingly random characters that may be the same (see row ids 9 and 10)
- **lineItem/ResourceId** has records that hold account numbers, we want to ensure that they are the same as **bill/PayerAccountId**
and **lineItem/UsageAccountId** for consistent data.

| id | identity/LineItemId                                  | bill/PayerAccountId | lineItem/UsageAccountId | lineItem/ProductCode | lineItem/ResourceId                          |
|----|------------------------------------------------------|---------------------|-------------------------|----------------------|----------------------------------------------|
| 1  | mggj00y7rig8p3xjma6rpzkvtrn98q4a0ortz9ddgquu0pv3xshq | 9876543210          | 9876543210              | AmazonS3             | cloudtrail-9876543210                        |
| 2  | t8ubihdw6ad39awf1748v98yim4uh6wyjzr59bziwwcfnyu4rxhf | 9876543210          | 9876543210              | AmazonS3             | cloudtrail-9876543210                        |
| 3  | 8c8u2fcetmrz3f0x52coe4wgjv77ffxx2ivgitg1a1nacpo8menv | 9876543210          | 9876543210              | AmazonCloudFront     | arn:aws:cloudfront::9876543210:Overhold      |
| 4  | 9jqoasom8qnxma5rjqhawkncrhev0ocsp4ax5pngrp8l1yno03v3 | 9876543210          | 9876543210              | AmazonS3             | aws-cloudtrail-logs-9876543210               |
| 5  | 35znibzyuoisze9x45377jqkbd7o677w4mhgl8hyte8born5h1h3 | 9876543210          | 9876543210              | AmazonCloudFront     | arn:aws:cloudfront::9876543210:Overhold      |
| 6  | tb8qzhsrqu0z613jervo541l7p95b5pq2k80m7hcsnqjjjs6jnlx | 9876543210          | 9876543210              | awskms               | arn:aws:kms:ap-southeast-2:9876543210:Zoolab |
| 7  | c0k9bpm5y5m1aoebsrlc2ozdgqoqjkyjy7z0hx7kv4y93gx8ioji | 9876543210          | 9876543210              | AWSLambda            | arn:aws:lambda:Trippledex                    |
| 8  | ju8pmo0qqn5c2tapej4toy3c95w08ym6uar9hllyf3r0oj1hoiya | 9876543210          | 9876543210              | AmazonEC2            | vol-3ef2aece632                              |
| 9  | f5kta3av4k5k2fve6l8g370bj41leqzkazsad28hjnu2xngn8f86 | 9876543210          | 9876543210              | AmazonS3             | cloudtrail-9876543210                        |
| 10 | f5kta3av4k5k2fve6l8g370bj41leqzkazsad28hjnu2xngn8f86 | 9876543210          | 9876543210              | AmazonS3             | cloudtrail-9876543210                        |

##### Configuration
```ruby
transform do
  # Operate on the "identity/LineItemId" column
  candidate column: "identity/LineItemId" do
    # Replace the full record with a random character string of 52 length, only consisting of 
    # lowercase and number values.
    with_translation { replace("full").with("character", length: 52, types: %w[lowercase number]) }
  end

  candidate column: "bill/PayerAccountId" do
    # Replace the full record with a placeholder named :account_number (See at bottom of file for placeholders)
    with_translation { replace("full").with("placeholder", name: :account_number) }
  end

  candidate column: "lineItem/UsageAccountId" do
    with_translation { replace("full").with("number", length: 10) }
  end

  candidate column: "lineItem/ResourceId" do
    # If there is a match (i-[my-group]), replace just the match group with a hex string of 10 length
    with_translation { replace("regex", regex_cg: "^i-(.*)").with("hex", length: 10) }
    # If there is a match (vol-[my-group]), replace just the match group with a hex string of 10 length
    with_translation { replace("regex", regex_cg: "^vol-(.*)").with("hex", length: 10) }
    # If the string contains a token :, replace the 4th element with the account_number placeholder.
    with_translation { replace("split", token: ":", index: 4).with("placeholder", name: :account_number) }
    # If the string contains a token -, replace the last element with the account_number placeholder.
    with_translation { replace("split", token: "-", index: -1).with("placeholder", name: :account_number) }
    # If the string contains a token :, replace the last element with the a Faker value Faker::App.name.
    with_translation { replace("split", token: ":", index: -1).with("faker", module: "App", method: "name") }

    # If no match is found, replace the whole match with a prefix hidden_ along with a random 10 char hex string
    if_no_match { replace("full").with("hex", prefix: "hidden_", length: 10) }
  end

  # Hardcoded values that we may wish to reference
  place_holders({account_number: 1_234_567_890})
end

export do
  # Export to terminal a table with only 10 rows.
  terminal title: "Exported", row_count: 10
end
```

With these rules, the above file becomes:

Output:

| id | identity/LineItemId                                  | bill/PayerAccountId | lineItem/UsageAccountId | lineItem/ProductCode | lineItem/ResourceId                          |
|----|------------------------------------------------------|---------------------|-------------------------|----------------------|----------------------------------------------|
| 1  | ozsmh5j4oqnfgnv7k82tx1yne4h62rt2rfiilo0clt306ts9ib9g | 1234567890          | 1234567890              | AmazonS3             | cloudtrail-1234567890                        |
| 2  | soha1946igwsaz8iju4a6q9305yd1cj9gluqwxu6lmjor1wf4yb0 | 1234567890          | 1234567890              | AmazonS3             | cloudtrail-1234567890                        |
| 3  | k5a29qle33aqoemi74m75pwmhv5xq4sau6e6pyc9pc93g6stzk8s | 1234567890          | 1234567890              | AmazonCloudFront     | arn:aws:cloudfront::1234567890:Latlux        |
| 4  | 9i0pxzj7mgfy2nnjhalxatck9xidqt55vvmopiotv23raaol9wh1 | 1234567890          | 1234567890              | AmazonS3             | aws-cloudtrail-logs-1234567890               |
| 5  | uvws7h5xqc8qov8ana6arxyr0urkhpgu9a0g3wzv1emq9z19bl9m | 1234567890          | 1234567890              | AmazonCloudFront     | arn:aws:cloudfront::1234567890:Latlux        |
| 6  | lhv6swfx2ulsfs8mpfrjutgq45kixouh0xjfvfo40g42757r7mje | 1234567890          | 1234567890              | awskms               | arn:aws:kms:ap-southeast-2:1234567890:Sonair |
| 7  | zm6gwy8c5qxbe24du6oipdls3iyjp83a3000z6p1l26xo44e0swa | 1234567890          | 1234567890              | AWSLambda            | arn:aws:lambda:Biodex                        |
| 8  | xcpy7jqbash47ckhyv8bnaqrf1tvsmrqq325vbebu550v7nnhef5 | 1234567890          | 1234567890              | AmazonEC2            | vol-1234567890                               |
| 9  | o1b4h0yvkw0jkbrhewqr1s0cd9abyqol1r90jtitu7vcr2e6qvcb | 1234567890          | 1234567890              | AmazonS3             | cloudtrail-1234567890                        |
| 10 | o1b4h0yvkw0jkbrhewqr1s0cd9abyqol1r90jtitu7vcr2e6qvcb | 1234567890          | 1234567890              | AmazonS3             | cloudtrail-1234567890                        |

Note that rows 9 and 10 have the same **identity/LineItemId**, and **lineItem/ResourceId** references our new made up account number.