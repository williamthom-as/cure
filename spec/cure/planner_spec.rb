# frozen_string_literal: true

require "json"
require "cure/planner"

RSpec.describe Cure::Planner do

  # rubocop:disable Metrics/BlockLength
  describe "#build" do
    it "will extract required sections" do
      source_file_loc = "../../../spec/cure/test_files/sectioned_csv.csv"
      template_file_loc = "../../../spec/cure/test_files/sectioned_template.json"

      Cure::Main.init_from_file_locations(template_file_loc, source_file_loc)
      planner = Cure::Planner.new

      expect { planner.process }.to output(<<~MESSAGE).to_stdout
        [INFO] Cure Execution Plan
        [INFO] =====
        [INFO] 
        [INFO] Source file location: /home/william/RubymineProjects/cure/lib/cure/helpers/../../../spec/cure/test_files/sectioned_csv.csv
        [INFO] Template file descriptor below
        [INFO] 
        [INFO] Extract
        [INFO] =====
        [INFO] 
        [INFO] [4] named ranges specified
        [INFO] -- default will extract values from -1
        [INFO] -- section_1 will extract values from B2:G6
        [INFO] -- section_2 will extract values from B9:H14
        [INFO] -- section_3 will extract values from B18:G20
        [INFO] 
        [INFO] [2] variables specified
        [INFO] -- new_field will extract single_field from A16
        [INFO] -- new_field_2 will extract single_field from B16
        [INFO] 
        [INFO] Build
        [INFO] =====
        [INFO] 
        [INFO] -- new_column from section_1 will be changed with Add Builder
        [INFO] 
        [INFO] Transforms
        [INFO] =====
        [INFO] 
        [INFO] -- new_column from section_1 will be changed with 1 translation
        [INFO] 	 -- Replacement: Cure::Strategy::FullStrategy, Generator: Cure::Generator::VariableGenerator
        [INFO] -- new_column from section_3 will be changed with 1 translation
        [INFO] 	 -- Replacement: Cure::Strategy::FullStrategy, Generator: Cure::Generator::VariableGenerator
        [INFO] 
        [INFO] No Placeholders specified.
      MESSAGE
      end
    # rubocop:enable Metrics/BlockLength
  end
end
