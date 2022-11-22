# frozen_string_literal: true

require "json"
require "cure/extract/named_range_processor"

RSpec.describe Cure::Extract::NamedRangeProcessor do
  before :all do
    @source_file_loc = "spec/cure/test_files/sectioned_csv.csv"
    @template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

    @main = Cure::Main.new
                      .with_csv_file(:pathname, Pathname.new(@source_file_loc))
                      .with_template(:file, Pathname.new(@template_file_loc))
                      .init
  end

  describe "#process_row" do
    it "will extract the bounds" do
      nrs = @main.config.template.extraction.named_ranges
      nr_processor = described_class.new(nrs)

      expect(nr_processor.calculate_row_bounds).to eq(1..19)
      expect(nr_processor.calculate_row_bounds.class).to eq(Range)

      idx = 0
      CSV.foreach("spec/cure/test_files/sectioned_csv.csv") do |row|
        nr_processor.process_row(idx, row)
        idx += 1
      end

      p nr_processor.results
    end
  end

end

