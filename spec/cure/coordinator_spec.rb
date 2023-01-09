# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"

RSpec.describe Cure::Coordinator do
  describe "#extract" do
    it "will extract required sections" do
      source_file_loc = "spec/cure/test_files/test_csv_file.csv"
      template_file_loc = "../../../spec/cure/test_files/test_template.json"

      Cure::Main.new
                .with_csv_file(:pathname, Pathname.new(source_file_loc))
                .with_template(:file, Pathname.new(template_file_loc))
                .init

      coordinator = Cure::Coordinator.new
      coordinator.send(:extract)

      rows = []
      coordinator.database_service.with_paged_result(:_default) do |row|
        rows << row
      end

      variables = []
      coordinator.database_service.with_paged_result(:variables) do |row|
        variables << row
      end

      expect(variables).to be_empty
      expect(coordinator.database_service.table_exists?("_default")).to eq(true)

      expect(rows.length).to be(3)
      expect(rows[0]).to eq({:id=>1, :test_column=>"abc", :test_column2=>"def"})
      expect(rows[1]).to eq({:id=>2, :test_column=>"abc", :test_column2=>"def"})
      expect(rows[2]).to eq({:id=>3, :test_column=>"abc", :test_column2=>"def"})
    end
  end

  describe "#extract" do
    it "will extract required sections" do
      source_file_loc = "spec/cure/test_files/sectioned_csv.csv"
      template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

      Cure::Main.new
                .with_csv_file(:pathname, Pathname.new(source_file_loc))
                .with_template(:file, Pathname.new(template_file_loc))
                .init

      coordinator = Cure::Coordinator.new
      coordinator.send(:extract)

      rows = []
      coordinator.database_service.with_paged_result(:section_1) do |row|
        rows << row
      end

      variables = []
      coordinator.database_service.with_paged_result(:variables) do |row|
        variables << row
      end

      expect(variables.map { |x| x[:name] }).to eq(%w[new_field new_field_2])
      expect(variables.map { |x| x[:value] }).to eq(%w[new_value new_value_2])

      expect(coordinator.database_service.table_exists?("section_1")).to eq(true)
      expect(coordinator.database_service.table_exists?("section_2")).to eq(false)
      expect(coordinator.database_service.table_exists?("section_3")).to eq(true)

      expect(coordinator.database_service.database[:section_1].count).to eq(4)
      expect(coordinator.database_service.database[:section_3].count).to eq(3)

      expect(rows.length).to be(4)
      expect(rows[0]).to eq({
        column_1: "a1",
        column_2: "a2",
        column_3: "a3",
        column_4: "a4",
        column_5: "a5",
        column_6: "a6",
        id: 2
      })
      expect(rows[1]).to eq({
        column_1: "b1",
        column_2: "b2",
        column_3: "b3",
        column_4: "b4",
        column_5: "b5",
        column_6: "b6",
        id: 3
      })
      expect(rows[2]).to eq({
        column_1: "c1",
        column_2: "c2",
        column_3: "c3",
        column_4: "c4",
        column_5: "c5",
        column_6: "c6",
        id: 4
      })
      expect(rows[3]).to eq({
        column_1: "d1",
        column_2: "d2",
        column_3: "d3",
        column_4: "d4",
        column_5: "d5",
        column_6: "d6",
        id: 5
      })
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
      coordinator.send(:extract)
      coordinator.send(:build)

      rows = []
      coordinator.database_service.with_paged_result(:section_1) do |row|
        rows << row
      end

      expect(coordinator.database_service.table_exists?("_default")).to eq(false)
      expect(rows.length).to eq(4)
      expect(rows[0].keys).to eq(%i(id column_1 column_2 column_3 column_4 column_5 column_6 new_column))

      expect(rows[0]).to eq({
                              column_1: "a1",
                              column_2: "a2",
                              column_3: "a3",
                              column_4: "a4",
                              column_5: "a5",
                              column_6: "a6",
                              id: 2,
                              new_column: nil
                            })
      expect(rows[1]).to eq({
                              column_1: "b1",
                              column_2: "b2",
                              column_3: "b3",
                              column_4: "b4",
                              column_5: "b5",
                              column_6: "b6",
                              id: 3,
                              new_column: nil
                            })
      expect(rows[2]).to eq({
                              column_1: "c1",
                              column_2: "c2",
                              column_3: "c3",
                              column_4: "c4",
                              column_5: "c5",
                              column_6: "c6",
                              id: 4,
                              new_column: nil
                            })
      expect(rows[3]).to eq({
                              column_1: "d1",
                              column_2: "d2",
                              column_3: "d3",
                              column_4: "d4",
                              column_5: "d5",
                              column_6: "d6",
                              id: 5,
                              new_column: nil
                            })

      # coordinator.send(:transform, wrapped_csv)
      # trans_csv = result.content["section_1"]
      #
      # expect(trans_csv.rows[0]).to eq(%w[a1 a2 a3 a4 a5 a6 new_value])
      # expect(trans_csv.rows[1]).to eq(%w[b1 b2 b3 b4 b5 b6 new_value])
      # expect(trans_csv.rows[2]).to eq(%w[c1 c2 c3 c4 c5 c6 new_value])
    end
    # rubocop:enable Metrics/BlockLength
  end

  # rubocop:disable Metrics/BlockLength
  describe "#process" do
    it "will extract required sections" do
      source_file_loc = "spec/cure/test_files/sectioned_csv.csv"
      template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

      Cure::Main.new
                .with_csv_file(:pathname, Pathname.new(source_file_loc))
                .with_template(:file, Pathname.new(template_file_loc))
                .init

      coordinator = Cure::Coordinator.new
      coordinator.process
    end
    # rubocop:enable Metrics/BlockLength
  end
end
