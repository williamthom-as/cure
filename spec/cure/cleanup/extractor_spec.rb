# frozen_string_literal: true

require "cure/cleanup/extractor"

RSpec.describe Cure::Cleanup::Extractor do
  describe "#array_position" do
    it "should create an array position list from input" do
      arr = Cure::Cleanup::Extractor.new({}).array_position_lookup("B2:C3")
      expect(arr).to eq([1, 2, 1, 2])
    end

    it "should handle -1 as entire sheet" do
      arr = Cure::Cleanup::Extractor.new({}).array_position_lookup(-1)
      expect(arr).to eq([0, -1, 0, -1])
    end

    it "should create subset array from a named range" do
      test_arr = [
        %w[a1 b1 c1 d1],
        %w[a2 b2 c2 d2],
        %w[a3 b3 c3 d3],
        %w[a4 b4 c4 d4]
      ]

      arr = Cure::Cleanup::Extractor.new({}).extract_from_rows(test_arr, "B2:C3")
      expect(arr).to eq([%w[b2 c2], %w[b3 c3]])
    end

    it "should return entire range when default" do
      test_arr = [
        %w[a1 b1 c1 d1],
        %w[a2 b2 c2 d2],
        %w[a3 b3 c3 d3],
        %w[a4 b4 c4 d4]
      ]

      arr = Cure::Cleanup::Extractor.new({}).extract_from_rows(test_arr, -1)
      expect(arr).to eq(test_arr)
    end
  end

  describe "#transform" do
    it "should load appropriately" do
      source_file_loc = "../../spec/cure/test_files/sectioned_csv.csv"
      template_file_loc = "../../spec/cure/test_files/sectioned_template.json"

      main = Cure::Main.init_from_file(template_file_loc, source_file_loc, "/tmp")
      @transform = Cure::Transformation::Transform.new(main.config.template.transformations.candidates)

      result = @transform.extract_from_file(source_file_loc)[1]
      expect(result.row_count).to eq(5)
      expect(result.transformed_rows.map { |r| r[0] }.join("").length).to eq(48)
    end
  end

  describe "#transform" do
    it "should load appropriately" do
      source_file_loc = "../../spec/cure/test_files/unsectioned_csv.csv"
      template_file_loc = "../../spec/cure/test_files/unsectioned_template.json"

      main = Cure::Main.init_from_file(template_file_loc, source_file_loc, "/tmp")
      @transform = Cure::Transformation::Transform.new(main.config.template.transformations.candidates)

      result = @transform.extract_from_file(source_file_loc)[0]
      expect(result.row_count).to eq(5)
      expect(result.transformed_rows.map { |r| r[0] }.join("").length).to eq(48)
    end
  end
end
