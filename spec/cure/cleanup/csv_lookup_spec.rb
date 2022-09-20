# frozen_string_literal: true

require "cure/preprocessor/csv_lookup"

RSpec.describe Cure::Preprocessor::CsvLookup do
  describe "#array_position" do
    it "should create an array position list from input" do
      arr = described_class.array_position_lookup("B2:C3")
      expect(arr).to eq([1, 2, 1, 2])
    end

    it "should handle -1 as entire sheet" do
      arr = described_class.array_position_lookup(-1)
      expect(arr).to eq([0, -1, 0, -1])
    end
  end
end
