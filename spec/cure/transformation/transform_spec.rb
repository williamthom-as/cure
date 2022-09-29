# frozen_string_literal: true

require "json"
require "cure/transformation/candidate"

RSpec.describe Cure::Transformation::Transform do
  before :all do
    @source_file_loc = "../../../spec/cure/test_files/test_csv_file.csv"
    template_file_loc = "../../../spec/cure/test_files/test_template.json"

    main = Cure::Main.init_from_file(template_file_loc, @source_file_loc, "/tmp")
    @transform = Cure::Transformation::Transform.new(main.config.template.transformations.candidates)
  end

  describe "#transform" do
    it "should load appropriately" do
      result = @transform.extract_from_file(@source_file_loc)["default"]
      expect(result.row_count).to eq(4)
      expect(result.transformed_rows.map { |a| a[0] }.uniq.length).to eq(1)
    end
  end
end
