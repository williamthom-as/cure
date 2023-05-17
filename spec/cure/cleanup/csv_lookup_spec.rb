# frozen_string_literal: true

require "cure/extract/csv_lookup"

RSpec.describe Cure::Extract::CsvLookup do
  describe "#array_position" do
    it "should create an array position list from input" do
      arr = described_class.array_position_lookup("B2:C3")
      expect(arr).to eq([1, 2, 1, 2])
    end

    it "should create an array position list from multiple column letter input" do
      arr = described_class.array_position_lookup("A1:AMJ2")
      expect(arr).to eq([0, 1023, 0, 1])
    end

    it "should handle -1 as entire sheet" do
      arr = described_class.array_position_lookup(-1)
      expect(arr).to eq([0, 1_023, 0, 10000000])
    end
  end

  describe "#position_for_letter" do
    it "should find position for a single-character column" do
      val = described_class.position_for_letter("A")
      expect(val).to eq(0)

      val_2 = described_class.position_for_letter("C")
      expect(val_2).to eq(2)
    end

    it "should find position for a multi-character column" do
      arr = described_class.position_for_letter("AMJ")
      expect(arr).to eq(1023)
    end
  end
end
