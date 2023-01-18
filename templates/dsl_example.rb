csv file: "location", encoding: "utf-8"

extraction do
  named_range name: "section_1", at: "B2:G6"
  named_range name: "section_2", at: "B18:G20", headers: "B2:G2"

  variable name: "new_field", location: "A16"
  variable name: "new_field_2", location: "B16"
end

build do
  candidate column: "new_column", named_range: "section_1" do
    add options: {}
  end
end

transformations do
  candidate column: "new_column", named_range: "section_1" do
    strategy name: "full", options: {}
    generator name: "variable", options: {
      name: "new_field"
    }
  end

  candidate column: "new_column", named_range: "section_2" do
    strategy name: "full", options: {}
    generator name: "variable", options: {
      name: "new_field"
    }
  end

  placeholders({key: "value", key2: "value2"})
end

exporters do
  terminal named_range: "section_1", title: "Exported", limit_rows: 5
  csv named_range: "section_1", file: "/tmp/cure/section_1.csv"
  csv named_range: "section_2", file: "/tmp/cure/section_2.csv"
end
