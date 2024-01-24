# frozen_string_literal: true

require "json"
require "cure/extract/variable_processor"

RSpec.describe Cure::Extract::VariableProcessor do
  before :all do
    @source_file_loc = "spec/cure/test_files/sectioned_csv.csv"

    @main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/sectioned_csv.csv"))
    @main.with_config do
      extract do
        named_range name: "section_1", at: "B2:G6"
        named_range name: "section_2", at: "B9:H14"
        named_range name: "section_3", at: "B18:G20", headers: "B2:G2"
        variable name: "new_field", at: "A16"
        variable name: "new_field_2", at: "B16"
      end

      build do
        candidate column: "new_column", named_range: "section_1" do
          add options: {}
        end
      end

      transform do
        candidate column: "new_column", named_range: "section_1" do
          with_translation { replace("full").with("variable", name: "new_field")}
        end

        candidate column: "new_column", named_range: "section_3" do
          with_translation { replace("full").with("variable", name: "new_field")}
        end
      end
    end
    @main.setup
  end

  describe "#process_row" do
    it "will extract the bounds" do
      db_svc = Cure::DatabaseService.new

      vs = @main.config.template.extraction.variables
      v_processor = described_class.new(db_svc, vs)

      expect(v_processor.candidate_rows).to eq([15, 15])
      expect(v_processor.candidate_rows.class).to eq(Array)

      idx = 0
      CSV.foreach("spec/cure/test_files/sectioned_csv.csv") do |row|
        v_processor.process_row(idx, row)
        idx += 1
      end

      results = []
      v_processor.database_service.with_paged_result(:variables) do |row|
        results << row
      end

      expect(results[0]).to eq({:_id=>1, :name=>"new_field", :value=>"new_value"})
      expect(results[1]).to eq({:_id=>2, :name=>"new_field_2", :value=>"new_value_2"})
    end
  end
end


