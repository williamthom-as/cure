# frozen_string_literal: true

require "cure/dsl/template"

RSpec.describe Cure::Dsl::DslHandler do
  describe "#generate" do
    it "should return a valid extraction template from dsl" do
      doc = <<-TEMPLATE
        extract do
          named_range name: "section_1", at: "B2:G6"
          named_range name: "section_2", at: "C2:H6"
          named_range name: "section_3", at: -1
          named_range name: "section_4" do
            columns {
              with(source: "identifier", as: "id")
              with(source: "name")
            }       
                
            rows {
              start(where: "a")
              finish(where: "a")
              including(where: "a")
            }
          end 

          variable name: "new_field", at: "A16"
          sample(rows: 5)
        end
      TEMPLATE

      template = described_class.init_from_content(doc, "test_file")
      result = template.generate

      expect(result.extraction.class).to be(Cure::Dsl::Extraction)

      expect(result.extraction.named_ranges.size).to eq(4)
      expect(result.extraction.named_ranges[0].name).to eq("section_1")
      expect(result.extraction.named_ranges[0].section).to eq([1, 6, 1, 5])
      expect(result.extraction.named_ranges[1].name).to eq("section_2")
      expect(result.extraction.named_ranges[1].section).to eq([2, 7, 1, 5])
      expect(result.extraction.named_ranges[2].name).to eq("section_3")
      expect(result.extraction.named_ranges[2].section).to eq([0, 1023, 0, 10000000])
      expect(result.extraction.named_ranges[3].name).to eq("section_4")
      expect(result.extraction.named_ranges[3].section).to eq([0, 1023, 0, 10000000])
      expect(result.extraction.named_ranges[3].filter.col_handler.definitions.size).to eq(2)
      expect(result.extraction.named_ranges[3].filter.row_handler.start_proc).to eq({where: "a", options:{}})
      expect(result.extraction.named_ranges[3].filter.row_handler.finish_proc).to eq({where: "a", options:{}})
      expect(result.extraction.named_ranges[3].filter.row_handler.including_proc).to eq({where: "a", options:{}})
      expect(result.extraction.variables.size).to eq(1)
      expect(result.extraction.variables[0].name).to eq("new_field")
      expect(result.extraction.variables[0].location).to eq([0, 15])
      expect(result.extraction.sample_rows).to eq(5)
    end

    it "should return a valid validation template from dsl" do
      doc = <<-TEMPLATE
        validate do
          candidate column: "new_column", named_range: "section_1", options: { fail_on_error: false } do
            with_rule :not_null
            with_rule :length, { min: 0, max: 5 }
            with_rule :custom, { proc: Proc.new { |x| x > 1 } }
          end
        end
      TEMPLATE

      template = described_class.init_from_content(doc, "test_file")
      result = template.generate

      expect(result.validator.class).to be(Cure::Dsl::Validator)
      expect(result.validator.candidates.size).to eq(1)
      expect(result.validator.candidates[0].column).to eq("new_column")
      expect(result.validator.candidates[0].named_range).to eq("section_1")
      expect(result.validator.candidates[0].rules[0].class).to eq(Cure::Validator::NotNullRule)
      expect(result.validator.candidates[0].rules[1].class).to eq(Cure::Validator::LengthRule)
      expect(result.validator.candidates[0].rules[2].class).to eq(Cure::Validator::CustomRule)
    end

    it "should return a valid builder template from dsl" do
      doc = <<-TEMPLATE
        build do
          candidate column: "new_column", named_range: "section_1" do
            add options: {}
          end
        end
      TEMPLATE

      template = described_class.init_from_content(doc, "test_file")
      result = template.generate

      expect(result.builder.class).to be(Cure::Dsl::Builder)
      expect(result.builder.candidates.size).to eq(1)
      expect(result.builder.candidates[0].column).to eq("new_column")
      expect(result.builder.candidates[0].named_range).to eq("section_1")
      expect(result.builder.candidates[0].action.class).to eq(Cure::Builder::AddBuilder)
    end

    it "should return a valid query template from dsl" do
      doc = <<-TEMPLATE
        query do
          with named_range: "section_1", query: <<-SQL
            SELECT * FROM section_1
          SQL

          with named_range: "section_2", query: <<-SQL
            SELECT * FROM section_2
          SQL
        end
      TEMPLATE

      template = described_class.init_from_content(doc, "test_file")
      result = template.generate

      expect(result.queries.class).to be(Cure::Dsl::Queries)
      expect(result.queries.candidates.size).to eq(2)
      expect(result.queries.candidates[0].named_range).to eq(:section_1)
      expect(result.queries.candidates[0].query).to include("SELECT * FROM section_1")
      expect(result.queries.find("section_1").named_range).to eq(:section_1)
      expect(result.queries.find(:section_1).named_range).to eq(:section_1)
    end

    it "should return a valid transformations template from dsl" do
      doc = <<-TEMPLATE
        transform do
          candidate(column: "new_column", named_range: "section_1") do
            with_translation { replace("regex", regex_cg: "^vol-(.*)").with("variable", name: "new_field") }
            with_translation { replace("split", "token": ":", "index": 4).with("placeholder", name: "key2") }
            if_no_match { replace("full").with("placeholder", name: "key2") }
          end
        
          place_holders({key: "value", key2: "value2"})
        end
      TEMPLATE

      template = described_class.init_from_content(doc, "test_file")
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

      template = described_class.init_from_content(doc, "test_file")
      result = template.generate

      expect(result.exporters.class).to eq(Cure::Dsl::Exporters)
      expect(result.exporters.processors.size).to eq(3)
      expect(result.exporters.processors[0].class).to eq(Cure::Export::TerminalProcessor)
      expect(result.exporters.processors[1].class).to eq(Cure::Export::CsvProcessor)
      expect(result.exporters.processors[2].class).to eq(Cure::Export::CsvProcessor)
    end

    it "should return a valid exporter template from dsl" do
      doc = <<-TEMPLATE
        metadata do
          name "OpenPL Dataset"
          version "1"
          comments "A useless comment"
          additional data: {
            a: "b"
          }
        end
      TEMPLATE

      template = described_class.init_from_content(doc, "test_file")
      result = template.generate

      expect(result.meta_data.class).to eq(Cure::Dsl::Metadata)
      expect(result.meta_data._name).to eq("OpenPL Dataset")
      expect(result.meta_data._version).to eq("1")
      expect(result.meta_data._additional).to eq({a: "b"})
    end

    it "should return valid source files from dsl" do
      doc = <<-TEMPLATE
        sources do
          csv :pathname, Pathname.new("spec/cure/e2e/input/simple_names.csv"), ref_name: "names"
          csv :pathname, Pathname.new("spec/cure/e2e/input/simple_ages.csv"), ref_name: "ages"
        end
      TEMPLATE

      template = described_class.init_from_content(doc, "test_file")
      result = template.generate

      expect(result.source_files.class).to eq(Cure::Dsl::SourceFiles)
      expect(result.source_files.candidates.size).to eq(2)
    end

    it "should return database config from dsl" do
      doc = <<-TEMPLATE
        database do
          persisted(file_path: "/tmp/dir/database_run")
        end
      TEMPLATE

      template = described_class.init_from_content(doc, "test_file")
      result = template.generate

      expect(result.database_config.class).to eq(Cure::Dsl::DatabaseConfig)
      expect(result.database_config.settings.file_path).to eq("/tmp/dir/database_run")
      expect(result.database_config.settings.drop_table_on_initialise).to eq(false) # default
    end

    it "should run from block" do
      template = described_class.init do
        extract do
          named_range name: "section_1", at: "B2:G6"
          named_range name: "section_2", at: "C2:H6"
          variable name: "new_field", at: "A16"
        end
      end
      result = template.generate

      expect(result.extraction.class).to be(Cure::Dsl::Extraction)
    end
  end
end
