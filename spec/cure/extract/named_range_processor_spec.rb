# frozen_string_literal: true

require "json"
require "cure/extract/named_range_processor"

RSpec.describe Cure::Extract::NamedRangeProcessor do
  before :all do
    @source_file_loc = "spec/cure/test_files/sectioned_csv.csv"
    @template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

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

      nrs = @main.config.template.extraction.named_ranges
      nr_processor = described_class.new(db_svc, nrs)

      expect(nr_processor.calculate_row_bounds).to eq(1..19)
      expect(nr_processor.calculate_row_bounds.class).to eq(Range)

      idx = 0
      CSV.foreach("spec/cure/test_files/sectioned_csv.csv") do |row|
        nr_processor.process_row(idx, row)
        idx += 1
      end

      nr_processor.after_process

      results = []
      nr_processor.database_service.with_paged_result(:section_1) do |row|
        results << row
      end

      expect(results[0]).to eq({:_id=>1, :column_1=>"a1", :column_2=>"a2", :column_3=>"a3", :column_4=>"a4", :column_5=>"a5", :column_6=>"a6"})
      expect(results[1]).to eq({:_id=>2, :column_1=>"b1", :column_2=>"b2", :column_3=>"b3", :column_4=>"b4", :column_5=>"b5", :column_6=>"b6"})
      expect(results[2]).to eq({:_id=>3, :column_1=>"c1", :column_2=>"c2", :column_3=>"c3", :column_4=>"c4", :column_5=>"c5", :column_6=>"c6"})
      expect(results[3]).to eq({:_id=>4, :column_1=>"d1", :column_2=>"d2", :column_3=>"d3", :column_4=>"d4", :column_5=>"d5", :column_6=>"d6"})
    end
  end

end

