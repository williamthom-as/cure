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
      expect(result.extraction.named_ranges[0].section).to eq([1, 6, 1, 5])
      expect(result.extraction.named_ranges[1].name).to eq("section_2")
      expect(result.extraction.named_ranges[1].section).to eq([2, 7, 1, 5])

      expect(result.extraction.variables.size).to eq(1)
      expect(result.extraction.variables[0].name).to eq("new_field")
      expect(result.extraction.variables[0].location).to eq([0, 15])
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
            with_translation { replace("regex", regex_cg: "^vol-(.*)").with("variable", name: "new_field") }
            with_translation { replace("split", "token": ":", "index": 4).with("placeholder", name: "key2") }
            if_no_match { replace("full").with("placeholder", name: "key2") }
          end
        
          placeholders({key: "value", key2: "value2"})
        end
      TEMPLATE

      template = described_class.new(doc, "test_file")
      result = template.generate
      candidate = result.transformations.candidates[0]

      expect(result.transformations.class).to be(Cure::Dsl::Transformations)
      expect(result.transformations.candidates.size).to eq(1)
      expect(candidate.column).to eq("new_column")
      expect(candidate.named_range).to eq("section_1")
      expect(candidate.translations.size).to eq(2)
      expect(candidate.translations[0].generator.class).to eq(Cure::Generator::VariableGenerator)
      expect(candidate.translations[0].strategy.class).to eq(Cure::Strategy::RegexStrategy)
      expect(candidate.no_match_translation.generator.class).to eq(Cure::Generator::PlaceholderGenerator)
      expect(candidate.no_match_translation.strategy.class).to eq(Cure::Strategy::FullStrategy)
    end

    it "should return a valid exporter template from dsl" do
      doc = <<-TEMPLATE
        export do
          terminal named_range: "section_1", title: "Exported", limit_rows: 5
          csv named_range: "section_1", file: "/tmp/cure/section_1.csv"
          csv named_range: "section_2", file: "/tmp/cure/section_2.csv"
        end
      TEMPLATE

      template = described_class.new(doc, "test_file")
      result = template.generate

      expect(result.exporters.class).to be(Cure::Dsl::Exporters)
      expect(result.exporters.processors.size).to be(3)
      expect(result.exporters.processors[0].class).to be(Cure::Export::TerminalProcessor)
      expect(result.exporters.processors[1].class).to be(Cure::Export::CsvProcessor)
      expect(result.exporters.processors[2].class).to be(Cure::Export::CsvProcessor)
    end

  end
end

# Cure.configure do
#   csv file: "location", encoding: "utf-8"
#   ...
# end