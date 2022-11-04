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

      expect { planner.process }.to output("hello\n").to_stdout
    end
    # rubocop:enable Metrics/BlockLength
  end
end
