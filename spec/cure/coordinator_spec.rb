# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"

RSpec.describe Cure::Coordinator do
  describe "#extract" do
    it "will extract required sections" do
      main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/test_csv_file.csv"))
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
      main.setup

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
      expect(rows[0]).to eq({:_id=>1, :test_column=>"abc", :test_column2=>"def"})
      expect(rows[1]).to eq({:_id=>2, :test_column=>"abc", :test_column2=>"def"})
      expect(rows[2]).to eq({:_id=>3, :test_column=>"abc", :test_column2=>"def"})
    end
  end

  describe "#extract" do
    it "will extract required sections" do
      main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/sectioned_csv.csv"))
      main.with_config do
        extract do
          named_range name: "section_1", at: "B2:G6"
          named_range name: "section_2", at: "B9:H14"
          named_range name: "section_3", at: "B18:G20", headers: "B2:G2"
          variable name: "new_field", at: "A16"
          variable name: "new_field_2", at: "B16"
        end

        build do
          candidate column: "new_column", named_range: "section_1" do
            add options: {}
          end
        end

        transform do
          candidate column: "new_column", named_range: "section_1" do
            with_translation { replace("full").with("variable", name: "new_field")}
          end

          candidate column: "new_column", named_range: "section_3" do
            with_translation { replace("full").with("variable", name: "new_field")}
          end
        end
      end
      main.setup

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
      expect(coordinator.database_service.table_exists?("section_2")).to eq(true)
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
        _id: 2
      })
      expect(rows[1]).to eq({
        column_1: "b1",
        column_2: "b2",
        column_3: "b3",
        column_4: "b4",
        column_5: "b5",
        column_6: "b6",
        _id: 3
      })
      expect(rows[2]).to eq({
        column_1: "c1",
        column_2: "c2",
        column_3: "c3",
        column_4: "c4",
        column_5: "c5",
        column_6: "c6",
        _id: 4
      })
      expect(rows[3]).to eq({
        column_1: "d1",
        column_2: "d2",
        column_3: "d3",
        column_4: "d4",
        column_5: "d5",
        column_6: "d6",
        _id: 5
      })
    end
  end

  # rubocop:disable Metrics/BlockLength
  describe "#build" do
    it "will extract required sections" do
      main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/sectioned_csv.csv"))
      main.with_config do
        extract do
          named_range name: "section_1", at: "B2:G6"
          named_range name: "section_2", at: "B9:H14"
          named_range name: "section_3", at: "B18:G20", headers: "B2:G2"
          variable name: "new_field", at: "A16"
          variable name: "new_field_2", at: "B16"
        end

        build do
          candidate column: "new_column", named_range: "section_1" do
            add options: {}
          end
        end

        transform do
          candidate column: "new_column", named_range: "section_1" do
            with_translation { replace("full").with("variable", name: "new_field")}
          end

          candidate column: "new_column", named_range: "section_3" do
            with_translation { replace("full").with("variable", name: "new_field")}
          end
        end
      end
      main.setup

      coordinator = Cure::Coordinator.new
      coordinator.send(:extract)
      coordinator.send(:build)

      rows = []
      coordinator.database_service.with_paged_result(:section_1) do |row|
        rows << row
      end

      expect(coordinator.database_service.table_exists?("_default")).to eq(false)
      expect(rows.length).to eq(4)
      expect(rows[0].keys).to eq(%i(_id column_1 column_2 column_3 column_4 column_5 column_6 new_column))

      expect(rows[0]).to eq({
                              column_1: "a1",
                              column_2: "a2",
                              column_3: "a3",
                              column_4: "a4",
                              column_5: "a5",
                              column_6: "a6",
                              _id: 2,
                              new_column: nil
                            })
      expect(rows[1]).to eq({
                              column_1: "b1",
                              column_2: "b2",
                              column_3: "b3",
                              column_4: "b4",
                              column_5: "b5",
                              column_6: "b6",
                              _id: 3,
                              new_column: nil
                            })
      expect(rows[2]).to eq({
                              column_1: "c1",
                              column_2: "c2",
                              column_3: "c3",
                              column_4: "c4",
                              column_5: "c5",
                              column_6: "c6",
                              _id: 4,
                              new_column: nil
                            })
      expect(rows[3]).to eq({
                              column_1: "d1",
                              column_2: "d2",
                              column_3: "d3",
                              column_4: "d4",
                              column_5: "d5",
                              column_6: "d6",
                              _id: 5,
                              new_column: nil
                            })

      # coordinator.send(:transform)
      # trans_csv = result.content["section_1"]
      #
      # expect(trans_csv.rows[0]).to eq(%w[a1 a2 a3 a4 a5 a6 new_value])
      # expect(trans_csv.rows[1]).to eq(%w[b1 b2 b3 b4 b5 b6 new_value])
      # expect(trans_csv.rows[2]).to eq(%w[c1 c2 c3 c4 c5 c6 new_value])
    end
    # rubocop:enable Metrics/BlockLength
  end

  # rubocop:disable Metrics/BlockLength
  # describe "#process" do
  #   it "will extract required sections" do
  #     source_file_loc = "spec/cure/test_files/sectioned_csv.csv"
  #     template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"
  #
  #     Cure::Launcher.new
  #               .with_csv_file(:pathname, Pathname.new(source_file_loc))
  #               .with_template(:file, Pathname.new(template_file_loc))
  #               .setup
  #
  #     coordinator = Cure::Coordinator.new
  #     coordinator.process
  #   end
  #   # rubocop:enable Metrics/BlockLength
  # end
end
