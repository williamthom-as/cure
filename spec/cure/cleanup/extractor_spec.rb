# frozen_string_literal: true

require "cure/extract/extractor"

# rubocop:disable Metrics/BlockLength
RSpec.describe Cure::Extract::Extractor do
  describe "#array_position" do
    it "should create subset array from a named range" do
      test_arr = [
        %w[a1 b1 c1 d1],
        %w[a2 b2 c2 d2],
        %w[a3 b3 c3 d3],
        %w[a4 b4 c4 d4]
      ]

      arr = described_class.new({}).extract_from_rows(test_arr, "B2:C3")
      expect(arr).to eq([%w[b2 c2], %w[b3 c3]])
    end

    it "should return entire range when default" do
      test_arr = [
        %w[a1 b1 c1 d1],
        %w[a2 b2 c2 d2],
        %w[a3 b3 c3 d3],
        %w[a4 b4 c4 d4]
      ]

      arr = described_class.new({}).extract_from_rows(test_arr, -1)
      expect(arr).to eq(test_arr)
    end
  end

  describe "#lookup_location" do
    it "will return the variable" do

      test_arr = [
        %w[a1 b1 c1 d1],
        %w[a2 b2 c2 d2],
        %w[a3 b3 c3 d3],
        %w[a4 b4 c4 d4]
      ]

      res = described_class.new({}).lookup_location(test_arr, "a1")
      expect(res).to eq("a1")
    end
  end

end
# rubocop:enable Metrics/BlockLength
