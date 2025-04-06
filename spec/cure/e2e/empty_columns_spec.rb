# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"
require "cure/log"

# This test involves removing bad data and only selected headers
RSpec.describe Cure::Coordinator do
  context "Process and rename empty columns" do
    describe "#extract" do
      it "will rename empty columns" do
        main = Cure::Launcher.new
          .with_csv_file(:pathname, Pathname.new("spec/cure/e2e/input/empty_columns.csv"))

        main.with_config do
          export do
            csv file_name: "empty_columns", directory: "/tmp/cure"
            terminal title: "Exported", limit_rows: 15
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        file_one = "/tmp/cure/empty_columns.csv"
        expect(File.exist? file_one).to eq(true)

        expected_file = "spec/cure/e2e/output/empty_columns_output.csv"
        expect(FileUtils.compare_file(file_one, expected_file)).to be_truthy
      end
    end
  end
end
