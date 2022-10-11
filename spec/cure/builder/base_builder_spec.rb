# frozen_string_literal: true

require "cure/builder/base_builder"

RSpec.describe Cure::Builder::ExplodeBuilder do
  before :all do
    @source_file_loc = "../../../spec/cure/test_files/explode_csv.csv"
    template_file_loc = "../../../spec/cure/test_files/explode_template.json"

    Cure::Main.init_from_file_locations(template_file_loc, @source_file_loc)
    @coordinator = Cure::Coordinator.new
  end

  describe "#process" do
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

      expect(exploder.safe_parse_json("dfsdfd")).to eq({})

      expect(result.content.first["content"].column_headers.keys).to eq(%w[index json abc def ghi])
      expect(result.content.first["content"].rows[0]).to eq(["1", "{\"abc\": \"def\",\"def\": 123}", "def", 123, ""])
      expect(result.content.first["content"].rows[1]).to eq(["2", "{\"abc\": \"def\",\"ghi\": 123}", "def", "", 123])
    end
  end

end

RSpec.describe Cure::Builder::RemoveBuilder do
  before :all do
    @source_file_loc = "../../../spec/cure/test_files/explode_csv.csv"
    template_file_loc = "../../../spec/cure/test_files/explode_template.json"

    Cure::Main.init_from_file_locations(template_file_loc, @source_file_loc)
    @coordinator = Cure::Coordinator.new
  end

  describe "#process" do
    it "will extract required sections" do
      wrapped_csv = @coordinator.send(:extract)

      opts = {
        "build" => {
          "candidates" => [
            {
              "column" => "json",
              "action" => {
                "name" => "remove",
                "options" => {}
              }
            }
          ]
        }
      }

      exploder = described_class.new(
        "default",
        opts["build"]["candidates"][0]["column"],
        opts["build"]["candidates"][0]["action"]["options"]
      )

      result = exploder.process(wrapped_csv)

      expect(result.content.first["content"].column_headers.keys).to eq(%w[index])
      expect(result.content.first["content"].rows[0]).to eq(["1"])
      expect(result.content.first["content"].rows[1]).to eq(["2"])
    end
  end
end

RSpec.describe Cure::Builder::AddBuilder do
  before :all do
    @source_file_loc = "../../../spec/cure/test_files/explode_csv.csv"
    template_file_loc = "../../../spec/cure/test_files/explode_template.json"

    Cure::Main.init_from_file_locations(template_file_loc, @source_file_loc)
    @coordinator = Cure::Coordinator.new
  end

  describe "#process" do
    it "will extract required sections" do
      wrapped_csv = @coordinator.send(:extract)

      opts = {
        "build" => {
          "candidates" => [
            {
              "column" => "new",
              "action" => {
                "name" => "add",
                "options" => {
                  "default_value" => "abc"
                }
              }
            }
          ]
        }
      }

      exploder = described_class.new(
        "default",
        opts["build"]["candidates"][0]["column"],
        opts["build"]["candidates"][0]["action"]["options"]
      )

      result = exploder.process(wrapped_csv)

      expect(result.content.first["content"].column_headers.keys).to eq(%w[index json new])
      expect(result.content.first["content"].rows[0]).to eq(["1", "{\"abc\": \"def\",\"def\": 123}", ""])
      expect(result.content.first["content"].rows[1]).to eq(["2", "{\"abc\": \"def\",\"ghi\": 123}", ""])
    end
  end
end

RSpec.describe Cure::Builder::BaseBuilder do
  describe "#process" do
    it "will raise if called on base" do
      expect { Cure::Builder::BaseBuilder.new("default","x", {}).process(nil) }.to raise_error
    end
  end
end
