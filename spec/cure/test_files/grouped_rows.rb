build do
  candidate column: "full_name" do
    add options: { default_value: "" }
  end
end

export do
  terminal title: "Exported", limit_rows: 5
end