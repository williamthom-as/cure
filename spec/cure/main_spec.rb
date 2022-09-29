# frozen_string_literal: true

require "json"
require "cure/config"

# rubocop:disable Metrics/BlockLength
RSpec.describe Cure::Main do
  describe "#init_from_file" do
    it "should set up the main service" do
      source_file_loc = "../../../spec/cure/test_files/test_csv_file.csv"
      template_file_loc = "../../../spec/cure/test_files/test_template.json"
      tmp_location = "/tmp/cure"

      main = Cure::Main.init_from_file(template_file_loc, source_file_loc, tmp_location)

      config = main.config
      expect(config.source_file_location).to eq(source_file_loc)
      expect(config.template.class).to eq(Cure::Template)
      expect(config.output_dir).to eq(tmp_location)
    end
  end

  describe "#init_from_template" do
    it "should set up the main service" do
      source_file_loc = "../../../spec/cure/test_files/test_csv_file.csv"
      tmp_location = "/tmp/cure"
      template = {
        "transformations" => {
          "candidates" => [{
            "column" => "my_col",
            "translations" => [{}]
          }],
          "placeholders" => []
        }
      }

      main = Cure::Main.init_from_hash(template, source_file_loc, tmp_location)

      config = main.config
      expect(config.source_file_location).to eq(source_file_loc)
      expect(config.template.class).to eq(Cure::Template)
      expect(config.output_dir).to eq(tmp_location)
    end
  end

  describe "#run_export" do
    it "should run export" do
      source_file_loc = "../../../spec/cure/test_files/test_csv_file.csv"
      template_file_loc = "../../../spec/cure/test_files/test_template.json"
      tmp_location = "/tmp/cure"

      main = Cure::Main.init_from_file(template_file_loc, source_file_loc, tmp_location)
      main.run_export

      main.with_temp_dir("/tmp/cure") do
        main.run_export
        expect(Dir["/tmp/cure/*.csv"].length.positive?).to be_truthy
      end

      expect(Dir["/tmp/cure/*.csv"].length.positive?).to be_falsey
    end
  end
end
# rubocop:enable Metrics/BlockLength
