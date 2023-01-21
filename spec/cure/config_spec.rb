# frozen_string_literal: true

require "json"
require "fileutils"
require "cure/config"

RSpec.describe Cure::Main do
  describe "#init" do
    it "should set up the main service" do
      source_file_loc = "spec/cure/test_files/test_csv_file.csv"

      main = Cure::Main.new.with_csv_file(:pathname, Pathname.new(source_file_loc))
      main.with_config {}
      main.init

      config = main.config
      expect(config.source_file.class).to eq(Cure::Configuration::CsvFileProxy)
      expect(config.template.class).to eq(Cure::Dsl::Template)
    end
  end
end
