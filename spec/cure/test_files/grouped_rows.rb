build do
  candidate column: "full_name" do
    add options: { default_value: "" }
  end
end

transform do
  candidate column: "gender" do
    with_translation { replace("full").with("case",
      statement: {
        "switch" => [
          {
            "case" => "male",
            "return_value" => "M"
          }, {
            "case" => "female",
            "return_value" => "F"
          }
        ],
        "else" => [
          "return_value" => "<unknown gender>"
        ]
      })
    }
  end

  candidate column: "full_name" do
    with_translation { replace("full").with("erb", template: "<%= first_name.capitalize %> <%= last_name.capitalize %>")}
  end
end

export do
  terminal title: "Exported", limit_rows: 5
end
