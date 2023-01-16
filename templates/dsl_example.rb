csv file: "location", encoding: ""

extraction do
  named_ranges do
    section name: "section_1", at: "B2:G6"
    section name: "section_2", at: "B9:H14"
    section name: "section_3", at: "B18:G20", headers: "B2:G2"
  end

  variables do
    variable name: "new_field", location: "A16"
    variable name: "new_field_2", location: "B16"
  end
end

build do
  candidate column: "new_column", named_range: "section_1" do
    add options: {}
  end
end

transformations do
  candidate column: "new_column", named_range: "section_1" do
    translations do
      strategy name: "full", options: {}
      generator name: "variable", options: {
        name: "new_field"
      }
    end
  end

  candidate column: "new_column", named_range: "section_3" do
    translations do
      strategy name: "full", options: {}
      generator name: "variable", options: {
        name: "new_field"
      }
    end
  end

  placeholders(
    {
      key: "value",
      key2: "value2"
    }
  )
end

