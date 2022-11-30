# frozen_string_literal: true

require "json"
require "cure/coordinator"

RSpec.describe Cure::Coordinator do
  describe "#extract" do
    it "will extract required sections" do
      source_file_loc = "spec/cure/test_files/sectioned_csv.csv"
      template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

      Cure::Main.new
                .with_csv_file(:pathname, Pathname.new(source_file_loc))
                .with_template(:file, Pathname.new(template_file_loc))
                .init

      result = []
      coordinator = Cure::Coordinator.new

      coordinator.send(:extract) do |row_ctx|
        result << row_ctx
      end

      expect(result[0].headers.keys).to eq(%w[column_1 column_2 column_3 column_4 column_5 column_6])
      expect(result[0].row).to eq(%w[a1 a2 a3 a4 a5 a6])
      expect(result[1].row).to eq(%w[b1 b2 b3 b4 b5 b6])
      expect(result[2].row).to eq(%w[c1 c2 c3 c4 c5 c6])
    end
  end

  # rubocop:disable Metrics/BlockLength
  describe "#build" do
    it "will extract required sections" do
      source_file_loc = "spec/cure/test_files/sectioned_csv.csv"
      template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

      Cure::Main.new
                .with_csv_file(:pathname, Pathname.new(source_file_loc))
                .with_template(:file, Pathname.new(template_file_loc))
                .init

      coordinator = Cure::Coordinator.new
      wrapped_csv = coordinator.send(:extract)
      result = coordinator.send(:build, wrapped_csv)

      expect(result.variables.keys).to eq(%w[new_field new_field_2])
      expect(result.content.length).to be(2)
      expect(result.content.keys).to eq(%w[section_1 section_3])

      expect { result.find_named_range("default") }.to raise_error(StandardError)

      csv = result.content["section_1"]

      expect(csv.row_count).to eq(4)
      expect(csv.rows.length).to be(4)
      expect(csv.column_headers.keys).to eq(
        %w[column_1 column_2 column_3 column_4 column_5 column_6 new_column]
      )
      expect(csv.rows[0]).to eq(["a1", "a2", "a3", "a4", "a5", "a6", ""])
      expect(csv.rows[1]).to eq(["b1", "b2", "b3", "b4", "b5", "b6", ""])
      expect(csv.rows[2]).to eq(["c1", "c2", "c3", "c4", "c5", "c6", ""])

      coordinator.send(:transform, wrapped_csv)
      trans_csv = result.content["section_1"]

      expect(trans_csv.rows[0]).to eq(%w[a1 a2 a3 a4 a5 a6 new_value])
      expect(trans_csv.rows[1]).to eq(%w[b1 b2 b3 b4 b5 b6 new_value])
      expect(trans_csv.rows[2]).to eq(%w[c1 c2 c3 c4 c5 c6 new_value])
    end
    # rubocop:enable Metrics/BlockLength
  end
end
