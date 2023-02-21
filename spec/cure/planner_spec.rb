# frozen_string_literal: true

require "json"
require "cure/planner"

RSpec.describe Cure::Planner do

  # rubocop:disable Metrics/BlockLength
  describe "#build" do
    it "will extract required sections" do
      @source_file_loc = "spec/cure/test_files/sectioned_csv.csv"

      @main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/sectioned_csv.csv"))
      @main.with_config do
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

      @main.setup

      planner = Cure::Planner.new

      # expect { planner.process }.to output(<<~MESSAGE).to_stdout
      #   [INFO] Cure Execution Plan
      #   [INFO] =====
      #   [INFO]
      #   [INFO] Source file location: sectioned_csv.csv
      #   [INFO] Template file descriptor below
      #   [INFO]
      #   [INFO] Extract
      #   [INFO] =====
      #   [INFO]
      #   [INFO] [4] named ranges specified
      #   [INFO] -- default will extract values from -1
      #   [INFO] -- section_1 will extract values from B2:G6
      #   [INFO] -- section_2 will extract values from B9:H14
      #   [INFO] -- section_3 will extract values from B18:G20
      #   [INFO]
      #   [INFO] [2] variables specified
      #   [INFO] -- new_field will extract single_field from A16
      #   [INFO] -- new_field_2 will extract single_field from B16
      #   [INFO]
      #   [INFO] Build
      #   [INFO] =====
      #   [INFO]
      #   [INFO] -- new_column from section_1 will be changed with Add Builder
      #   [INFO]
      #   [INFO] Transforms
      #   [INFO] =====
      #   [INFO]
      #   [INFO] -- new_column from section_1 will be changed with 1 translation
      #   [INFO] 	 -- Replacement: Cure::Strategy::FullStrategy, Generator: Cure::Generator::VariableGenerator
      #   [INFO] -- new_column from section_3 will be changed with 1 translation
      #   [INFO] 	 -- Replacement: Cure::Strategy::FullStrategy, Generator: Cure::Generator::VariableGenerator
      #   [INFO]
      #   [INFO] No Placeholders specified.
      # MESSAGE
      end
    # rubocop:enable Metrics/BlockLength
  end
end
