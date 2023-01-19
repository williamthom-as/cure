# frozen_string_literal: true

require "cure/dsl/template"

RSpec.describe Cure::Dsl::DslHandler do
  describe "#generate" do
    it "should return a valid extraction template from dsl" do
      doc = <<-TEMPLATE
        extract do
          named_range name: "section_1", at: "B2:G6"
          named_range name: "section_2", at: "C2:H6"
          variable name: "new_field", at: "A16"
        end
      TEMPLATE

      template = described_class.new(doc, "test_file")
      result = template.generate

      expect(result.extraction.class).to be(Cure::Dsl::Extraction)

      expect(result.extraction.named_ranges.size).to eq(2)
      expect(result.extraction.named_ranges[0].name).to eq("section_1")
      expect(result.extraction.named_ranges[0].at).to eq("B2:G6")
      expect(result.extraction.named_ranges[1].name).to eq("section_2")
      expect(result.extraction.named_ranges[1].at).to eq("C2:H6")

      expect(result.extraction.variables.size).to eq(1)
      expect(result.extraction.variables[0].name).to eq("new_field")
      expect(result.extraction.variables[0].at).to eq("A16")
    end

    it "should return a valid builder template from dsl" do
      doc = <<-TEMPLATE
        build do
          candidate column: "new_column", named_range: "section_1" do
            add options: {}
          end
        end
      TEMPLATE

      template = described_class.new(doc, "test_file")
      result = template.generate

      expect(result.builder.class).to be(Cure::Dsl::Builder)
      expect(result.builder.candidates.size).to eq(1)
      expect(result.builder.candidates[0].column).to eq("new_column")
      expect(result.builder.candidates[0].named_range).to eq("section_1")
      expect(result.builder.candidates[0].action.class).to eq(Cure::Builder::AddBuilder)
    end

    it "should return a valid transformations template from dsl" do
      doc = <<-TEMPLATE
        transform do
          candidate(column: "new_column", named_range: "section_1") do
            translation { replace("regex", regex_cg: "^vol-(.*)").with("variable", name: "new_field") }
            translation { replace("split", "token": ":", "index": 4).with("placeholder", name: "key2") }
            no_match_translation { replace("full").with("placeholder", name: "key2") }
          end
        
          placeholders({key: "value", key2: "value2"})
        end
      TEMPLATE

      template = described_class.new(doc, "test_file")
      result = template.generate

      expect(result.transformations.class).to be(Cure::Dsl::Transformations)
      expect(result.transformations.candidates.size).to eq(1)

    end
  end
end

# Cure.configure do
#   csv file: "location", encoding: "utf-8"
#   ...
# end