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
      db_svc = Cure::DatabaseService.new

      nrs = @main.config.template.extraction.named_ranges
      nr_processor = described_class.new(db_svc, nrs)

      expect(nr_processor.calculate_row_bounds).to eq(1..19)
      expect(nr_processor.calculate_row_bounds.class).to eq(Range)

      idx = 0
      CSV.foreach("spec/cure/test_files/sectioned_csv.csv") do |row|
        nr_processor.process_row(idx, row)
        idx += 1
      end

      nr_processor.database_service.with_paged_result(:section_1) do |row|
        puts row
      end


      # csv = nr_processor.results["section_1"]
      # expect(csv.column_headers.keys).to eq(%w[column_1 column_2 column_3 column_4 column_5 column_6])
      # expect(csv.rows[0]).to eq(%w[a1 a2 a3 a4 a5 a6])
      # expect(csv.rows[1]).to eq(%w[b1 b2 b3 b4 b5 b6])
      # expect(csv.rows[2]).to eq(%w[c1 c2 c3 c4 c5 c6])
    end
  end

end

