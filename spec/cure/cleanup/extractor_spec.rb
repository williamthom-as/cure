# frozen_string_literal: true

require "cure/cleanup/extractor"

RSpec.describe Cure::Cleanup::Extractor do
  describe "#array_position" do
    it "should create an array position list from input" do
      arr = Cure::Cleanup::Extractor.new({}).array_position_lookup("B2:C3")
      expect(arr).to eq([1, 2, 1, 2])
    end

    it "should create subset array from a named range" do
      test_arr = [
        %w[a1 b1 c1 d1],
        %w[a2 b2 c2 d2],
        %w[a3 b3 c3 d3],
        %w[a4 b4 c4 d4]
      ]

      arr = Cure::Cleanup::Extractor.new({}).extract(test_arr, "B2:C3")
      expect(arr).to eq([%w[b2 c2], %w[b3 c3]])
    end
  end
end
