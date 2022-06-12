# frozen_string_literal: true
#
require "cure/transformation/candidate"

RSpec.describe Cure::Transformation::Transform do

  column_headers = {
    "abc": 1,
    "def": 2
  }

  mock_csv_row = [1, 2]

  describe "#transform" do
    it "should load appropriately" do
      candidate = Cure::Transformation::Candidate.new
      candidate.column = "abc"
      candidate.strategy = "replace"
      candidate.generator = "number"
      candidate.options = {}


      tt = Cure::Transformation::Transform.new([candidate], column_headers)
      expect(tt.class).to eq(Cure::Transformation::Transform)

      new_row = tt.transform(mock_csv_row)
      puts new_row
    end
  end

end