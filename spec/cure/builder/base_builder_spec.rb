# frozen_string_literal: true

require "cure/builder/base_builder"

RSpec.describe Cure::Builder::ExplodeBuilder do
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

      exploder = Cure::Builder::ExplodeBuilder.new(
        "default",
        opts["build"]["candidates"][0]["column"],
        opts["build"]["candidates"][0]["action"]["options"]
      )

      result = exploder.process(wrapped_csv)

      expect(result.content.first["content"].column_headers.keys).to eq(%w[index json abc def ghi])
      expect(result.content.first["content"].rows[0]).to eq(["1", "{\"abc\": \"def\",\"def\": 123}", "def", 123, ""])
      expect(result.content.first["content"].rows[1]).to eq(["2", "{\"abc\": \"def\",\"ghi\": 123}", "def", "", 123])
    end
  end

end
