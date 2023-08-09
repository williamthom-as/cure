# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"
require "cure/log"

# This tests simple transforms and file export chunking to csv.
RSpec.describe Cure::Coordinator do
  context "Process and chunk a simple csv file" do
    describe "#extract" do
      it "will extract required sections" do
        main = Cure::Launcher.new
          .with_csv_file(:pathname, Pathname.new("spec/cure/e2e/input/simple_names.csv"))
          .with_csv_file(:pathname, Pathname.new("spec/cure/e2e/input/simple_ages.csv"))

        main.with_config do
          query do
            with query: <<-SQL
              SELECT 
                _default.identifier, 
                name, 
                age 
              FROM _default
              INNER JOIN _default_1 on _default.identifier = _default_1.identifier
            SQL
          end

          export do
            terminal title: "Exported", limit_rows: 5, named_range: "_default"
            csv file_name: "simple_joins", directory: "/tmp/cure", named_range: "_default"
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        file_one = "/tmp/cure/simple_joins.csv"
        expect(File.exist? file_one).to eq(true)

        expected_file = "spec/cure/e2e/output/simple_joins.csv"
        expect(FileUtils.compare_file(file_one, expected_file)).to be_truthy
      end
    end
  end
end
