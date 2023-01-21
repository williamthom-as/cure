# frozen_string_literal: true

require "json"
require "cure/transformation/candidate"

RSpec.describe Cure::Transformation::Transform do
  before :all do
    main = Cure::Main.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/test_csv_file.csv"))
    main.with_config do
      transform do
        candidate column: "test_column" do
          with_translation { replace("full").with("number", length: 12)}
        end
      end

      export do
        csv named_range: "_default", file: ""
      end
    end
    main.init

    @transform = Cure::Transformation::Transform.new(main.config.template.transformations.candidates)
  end

  describe "#transform" do
    it "should load appropriately" do
      # result = @transform.extract_from_file(@source_file_loc)["default"]
      # expect(result.row_count).to eq(4)
      # expect(result.transformed_rows.map { |a| a[0] }.uniq.length).to eq(1)
    end
  end
end
