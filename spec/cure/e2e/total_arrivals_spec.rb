# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"
require "cure/log"

require "fileutils"

# This tests missing column names, weird names, RFC4180 non compliant files.
RSpec.describe Cure::Coordinator do
  context "Process entire Total Arrivals file" do
    describe "#extract" do
      it "will extract required sections" do
        main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/e2e/input/total_arrivals_input.csv"))
        main.with_config do
          extract do
            named_range name: "travel_data", at: "A2:C124", headers: "A2:C2"
          end

          build do
            candidate(column: "col_0", named_range: "travel_data") {
              rename options: { "new_name" => "date"}
            }

            candidate(column: "\"Arrivals (M)\"", named_range: "travel_data") {
              rename options: { "new_name" => "arrivals"}
            }

            candidate(column: "\"Departures (M)\"", named_range: "travel_data") {
              rename options: { "new_name" => "departures"}
            }

            candidate(column: "difference", named_range: "travel_data") {
              add options: { default_value: "" }
            }

            candidate(column: "year", named_range: "travel_data") {
              add options: { default_value: "" }
            }
          end

          convert_columns = proc { |source, _ctx|
            (source.to_f * 1_000_000).to_i
          }

          transform do
            candidate named_range: "travel_data", column: "arrivals" do
              with_translation { replace("full").with("proc", execute: convert_columns) }
            end

            candidate named_range: "travel_data", column: "departures" do
              with_translation { replace("full").with("proc", execute: convert_columns) }
            end

            candidate named_range: "travel_data", column: "year" do
              with_translation { replace("full").with("proc", execute: proc { |_source, ctx|
                ctx.row[:arrivals].to_i - ctx.row[:departures].to_i
              }) }
            end

            candidate named_range: "travel_data", column: "difference" do
              with_translation { replace("full").with("proc", execute: proc { |_source, ctx|
                ctx.row[:arrivals].to_i - ctx.row[:departures].to_i
              }) }
            end

            candidate named_range: "travel_data", column: "year" do
              with_translation { replace("full").with("proc", execute: proc { |_source, ctx|
                ctx.row[:date].split(" ").last
              }) }
            end
          end

          export do
            terminal named_range: "travel_data", title: "Preview", limit_rows: 5
            csv named_range: "travel_data", file_name: "travel_data", directory: "/tmp/cure"
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        file_one = "/tmp/cure/travel_data.csv"
        expect(File.exist? file_one).to eq(true)

        expected_file = "spec/cure/e2e/output/total_arrivals_output.csv"
        expect(FileUtils.compare_file(file_one, expected_file)).to be_truthy
      end
    end
  end
end
