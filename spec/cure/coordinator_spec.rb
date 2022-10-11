# frozen_string_literal: true

require "json"
require "cure/coordinator"

RSpec.describe Cure::Coordinator do
  describe "#extract" do
    it "will extract required sections" do
      source_file_loc = "../../../spec/cure/test_files/test_csv_file.csv"
      template_file_loc = "../../../spec/cure/test_files/test_template.json"

      Cure::Main.init_from_file_locations(template_file_loc, source_file_loc, "/tmp")
      coordinator = Cure::Coordinator.new
      result = coordinator.send(:extract)

      expect(result.variables.keys).to be_empty
      expect(result.content.length).to be(1)

      csv = result.content.first

      expect(csv["name"]).to be("default")
      expect(csv["content"].rows.length).to be(3)
      expect(csv["content"].column_headers.keys).to eq(%w[test_column test_column2])
      expect(csv["content"].rows[0]).to eq(%w[abc def])
      expect(csv["content"].rows[1]).to eq(%w[abc def])
      expect(csv["content"].rows[2]).to eq(%w[abc def])
    end
  end

  describe "#extract" do
    it "will extract required sections" do
      source_file_loc = "../../../spec/cure/test_files/sectioned_csv.csv"
      template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

      Cure::Main.init_from_file_locations(template_file_loc, source_file_loc, "/tmp")
      coordinator = Cure::Coordinator.new
      result = coordinator.send(:extract)

      expect(result.variables.keys).to eq(%w[new_field new_field_2])
      expect(result.content.length).to be(1)

      csv = result.content.first

      expect(csv["name"]).to eq("section_1")
      expect(csv["content"].rows.length).to be(4)
      expect(csv["content"].column_headers.keys).to eq(%w[column_1 column_2 column_3 column_4 column_5 column_6])
      expect(csv["content"].rows[0]).to eq(%w[a1 a2 a3 a4 a5 a6])
      expect(csv["content"].rows[1]).to eq(%w[b1 b2 b3 b4 b5 b6])
      expect(csv["content"].rows[2]).to eq(%w[c1 c2 c3 c4 c5 c6])
    end
  end

  # rubocop:disable Metrics/BlockLength
  describe "#build" do
    it "will extract required sections" do
      source_file_loc = "../../../spec/cure/test_files/sectioned_csv.csv"
      template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

      Cure::Main.init_from_file_locations(template_file_loc, source_file_loc, "/tmp")
      coordinator = Cure::Coordinator.new
      wrapped_csv = coordinator.send(:extract)
      result = coordinator.send(:build, wrapped_csv)

      expect(result.variables.keys).to eq(%w[new_field new_field_2])
      expect(result.content.length).to be(1)
      expect { result.find_named_range("default") }.to raise_error(StandardError)

      csv = result.content.first
      expect(csv["content"].row_count).to eq(4)
      expect(csv["name"]).to eq("section_1")
      expect(csv["content"].rows.length).to be(4)
      expect(csv["content"].column_headers.keys).to eq(
        %w[column_1 column_2 column_3 column_4 column_5 column_6 new_column]
      )
      expect(csv["content"].rows[0]).to eq(["a1", "a2", "a3", "a4", "a5", "a6", ""])
      expect(csv["content"].rows[1]).to eq(["b1", "b2", "b3", "b4", "b5", "b6", ""])
      expect(csv["content"].rows[2]).to eq(["c1", "c2", "c3", "c4", "c5", "c6", ""])

      coordinator.send(:transform, wrapped_csv)
      trans_csv = result.content.first

      expect(trans_csv["content"].rows[0]).to eq(%w[a1 a2 a3 a4 a5 a6 new_value])
      expect(trans_csv["content"].rows[1]).to eq(%w[b1 b2 b3 b4 b5 b6 new_value])
      expect(trans_csv["content"].rows[2]).to eq(%w[c1 c2 c3 c4 c5 c6 new_value])
    end
    # rubocop:enable Metrics/BlockLength
  end
end
