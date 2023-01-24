extract do
  named_range name: "section_1", at: "A3:D5"
  variable name: "invoice_date", at: "F1"
end

build do
  candidate column: "invoice_date", named_range: "section_1" do
    add options: { default_value: "<missing>" }
  end
end

transform do
  candidate column: "invoice_date", named_range: "section_1" do
    with_translation { replace("full").with("variable", name: "invoice_date")}
  end
end

export do
  terminal title: "Exported", limit_rows: 5, named_range: "section_1"
end
