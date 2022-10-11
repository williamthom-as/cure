# frozen_string_literal: true

require "json"
require "fileutils"
require "cure/config"

RSpec.describe Cure::Main do
  describe "#init" do
    it "should set up the main service" do
      source_file_loc = "../../../spec/cure/test_files/test_csv_file.csv"
      template_file_loc = "../../../spec/cure/test_files/test_template.json"
      tmp_location = "/tmp/cure"

      main = Cure::Main.init_from_file_locations(template_file_loc, source_file_loc)

      config = main.config
      expect(config.source_file.class).to eq(File)
      expect(config.template.class).to eq(Cure::Template)
    end
  end
end
