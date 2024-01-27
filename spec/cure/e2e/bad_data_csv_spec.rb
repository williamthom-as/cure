# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"
require "cure/log"

# This test involves removing bad data and only selected headers
RSpec.describe Cure::Coordinator do
  context "Process and chunk a simple csv file" do
    describe "#extract" do
      it "will extract required sections" do
        main = Cure::Launcher.new
          .with_csv_file(:pathname, Pathname.new("spec/cure/e2e/input/names_with_errors.csv"))

        main.with_config do
          extract do
            named_range name: "names" do
              columns {
                with(source: "identifier", as: "id")
                with(source: "name")
              }

              rows {
                including(where: proc {|row| row.any? })
              }
            end
          end

          export do
            csv file_name: "names_with_errors", directory: "/tmp/cure", named_range: "names"
            terminal title: "Exported", limit_rows: 15, named_range: "names"
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        file_one = "/tmp/cure/names_with_errors.csv"
        expect(File.exist? file_one).to eq(true)

        expected_file = "spec/cure/e2e/output/names_with_errors.csv"
        expect(FileUtils.compare_file(file_one, expected_file)).to be_truthy
      end
    end
  end
end
