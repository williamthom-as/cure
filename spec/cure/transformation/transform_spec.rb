# frozen_string_literal: true

require "json"
require "cure/transformation/candidate"

RSpec.describe Cure::Transformation::Transform do
  before :all do
    @source_file_loc = "../../spec/cure/test_files/test_csv_file.csv"
    template_file_loc = "./spec/cure/test_files/test_template.json"

    json = JSON.parse(File.read(template_file_loc))
    candidates = json["candidates"].map { |x| Cure::Transformation::Candidate.new.from_json(x) }

    @transform = Cure::Transformation::Transform.new(candidates)
  end

  describe "#transform" do
    it "should load appropriately" do
      result = @transform.extract_from_file(@source_file_loc)
      expect(result.row_count).to eq(4)
      expect(result.transformed_rows.map { |a| a[0] }.uniq.length).to eq(1)
    end
  end
end
