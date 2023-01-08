# frozen_string_literal: true

require "json"
require "cure/extract/named_range_processor"

RSpec.describe Cure::Extract::VariableProcessor do
  before :all do
    @source_file_loc = "spec/cure/test_files/sectioned_csv.csv"
    @template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

    @main = Cure::Main.new
                      .with_csv_file(:pathname, Pathname.new(@source_file_loc))
                      .with_template(:file, Pathname.new(@template_file_loc))
                      .init
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

      expect(results[0]).to eq({:id=>1, :name=>"new_field", :value=>"new_value"})
      expect(results[1]).to eq({:id=>2, :name=>"new_field_2", :value=>"new_value_2"})
    end
  end

end


