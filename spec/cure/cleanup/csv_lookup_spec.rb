# frozen_string_literal: true

require "cure/extract/csv_lookup"

RSpec.describe Cure::Extract::CsvLookup do
  describe "#array_position" do
    it "should create an array position list from input" do
      arr = described_class.array_position_lookup("B2:C3")
      expect(arr).to eq([1, 2, 1, 2])
    end

    it "should handle -1 as entire sheet" do
      arr = described_class.array_position_lookup(-1)
      expect(arr).to eq([0, 100, 0, 10000000])
    end
  end
end
