build do
  candidate(column: "full_name") { add options: { default_value: "" } }
  candidate(column: "custom_field") { add options: { default_value: "" } }
end

query do
  with query: <<-SQL
    SELECT 
      id as id, 
      identifier as identifier, 
      group_concat(first_name, '') as first_name, 
      group_concat(last_name, '') as last_name, 
      group_concat(gender, '') as gender, 
      group_concat(age, '') as age, 
      full_name,
      custom_field
    FROM _default
    GROUP BY identifier
  SQL
end

transform do
  candidate column: "gender" do
    with_translation { replace("full").with("case",
      statement: {
        switch: [
          {
            case: "male",
            return_value: "M"
          }, {
            case: "female",
            return_value: "F"
          }
        ],
        else: [
          return_value: "<unknown gender>"
        ]
      })
    }
  end

  candidate column: "full_name" do
    with_translation { replace("full").with("erb", template: "<%= first_name.capitalize %> <%= last_name.capitalize %>")}
  end

  candidate column: "custom_field" do
    with_translation { replace("full").with(
      "proc",
      execute: proc do |source_val, row_ctx|
        if row_ctx.rows[:last_name] == "smith"
          "smith"
        else
          "#{source_val} -> #{row_ctx.rows[:last_name]}"
        end
      end
    )}
  end
end

export do
  terminal title: "Exported", limit_rows: 5
end
