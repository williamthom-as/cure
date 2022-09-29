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

  describe "#transform" do
    it "should load appropriately" do
      source_file_loc = "../../../spec/cure/test_files/sectioned_csv.csv"
      template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

      main = Cure::Main.init_from_file(template_file_loc, source_file_loc, "/tmp")
      # @transform = Cure::Transformation::Transform.new(main.config.template.transformations.candidates)

      # result = @transform.extract_from_file(source_file_loc)["section_1"]
      # expect(result.row_count).to eq(5)
      # expect(result.transformed_rows.map { |r| r[0] }.join("").length).to eq(48)
      # expect(result.transformed_rows.map { |r| r[1] }.join("")).to eq(
      #   "new_valuenew_value_2new_valuenew_value_2new_valuenew_value_2new_valuenew_value_2"
      # )
    end
  end

  describe "#transform" do
    it "should load appropriately" do
      source_file_loc = "../../../spec/cure/test_files/unsectioned_csv.csv"
      template_file_loc = "../../../spec/cure/test_files/unsectioned_template.json"

      main = Cure::Main.init_from_file(template_file_loc, source_file_loc, "/tmp")
      # @transform = Cure::Transformation::Transform.new(main.config.template.transformations.candidates)
      #
      # result = @transform.extract_from_file(source_file_loc)["default"]
      # expect(result.row_count).to eq(5)
      # expect(result.transformed_rows.map { |r| r[0] }.join("").length).to eq(48)
    end
  end
end
# rubocop:enable Metrics/BlockLength
