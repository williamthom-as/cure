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
        main.with_config do
          NAMES_SHEET = "names_sheet"
          AGES_SHEET = "ages_sheet"

          sources do
            csv :pathname, Pathname.new("spec/cure/e2e/input/complex_names.csv"), ref_name: NAMES_SHEET
            csv :pathname, Pathname.new("spec/cure/e2e/input/complex_ages.csv"), ref_name: AGES_SHEET
          end

          extract do
            named_range name: "names", at: "C3:E5", ref_name: NAMES_SHEET
            named_range name: "ages", at: "C3:E5", ref_name: AGES_SHEET

            variable name: "names_total", at: "E1", ref_name: NAMES_SHEET
            variable name: "ages_total", at: "E1", ref_name: AGES_SHEET
          end

          build do
            candidate(column: "names_total", named_range: "names") { add options: { default_value: "-" } }
            candidate(column: "ages_total", named_range: "names") { add options: { default_value: "-" } }
          end

          query do
            with named_range: "names", query: <<-SQL
              SELECT 
                names.id,
                first_name,
                last_name,
                color,
                age,
                names_total,
                ages_total
              FROM names
              INNER JOIN ages on names.id = ages.id
            SQL
          end

          transform do
            candidate named_range: "names", column: "names_total" do
              with_translation { replace("full", force_replace: true).with("variable", name: "names_total") }
            end

            candidate named_range: "names", column: "ages_total" do
              with_translation { replace("full", force_replace: true).with("variable", name: "ages_total") }
            end
          end

          export do
            terminal title: "Exported", limit_rows: 5, named_range: "names"
            csv file_name: "complex_joins", directory: "/tmp/cure", named_range: "names"
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        file_one = "/tmp/cure/complex_joins.csv"
        expect(File.exist? file_one).to eq(true)

        expected_file = "spec/cure/e2e/output/complex_joins.csv"
        expect(FileUtils.compare_file(file_one, expected_file)).to be_truthy
      end
    end
  end
end
