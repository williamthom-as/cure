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
      vs = @main.config.template.extraction.variables
      v_processor = described_class.new(vs)

      expect(v_processor.candidate_rows).to eq([15, 15])
      expect(v_processor.candidate_rows.class).to eq(Array)

      idx = 0
      CSV.foreach("spec/cure/test_files/sectioned_csv.csv") do |row|
        v_processor.process_row(idx, row)
        idx += 1
      end

      variables = v_processor.results
      expect(variables).to eq({"new_field"=>"new_value", "new_field_2"=>"new_value_2"})
    end
  end

end

