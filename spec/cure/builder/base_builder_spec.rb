# frozen_string_literal: true

require "cure/builder/base_builder"

RSpec.describe Cure::Builder::ExploderBuilder do
  before :all do
    @source_file_loc = "../../../spec/cure/test_files/explode_csv.csv"
    template_file_loc = "../../../spec/cure/test_files/explode_template.json"

    Cure::Main.init_from_file(template_file_loc, @source_file_loc, "/tmp")
    @coordinator = Cure::Coordinator.new
  end

  describe "#proces" do
    it "will extract required sections" do
      wrapped_csv = @coordinator.send(:extract)

      opts = {
        "build" => {
          "candidates" => [
            {
              "column" => "json",
              "action" => {
                "name" => "explode",
                "options" => {
                  "keep_existing" => false
                }
              }
            }
          ]
        }
      }

      exploder = Cure::Builder::ExploderBuilder.new(opts["build"]["candidates"].first)
      result = exploder.process(wrapped_csv)

      p result
    end
  end

end
