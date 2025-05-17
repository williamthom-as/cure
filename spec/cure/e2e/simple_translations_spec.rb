# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"
require "cure/log"

require "fileutils"

# This tests named ranges, variables, adding columns, inserting values, transforms, no nulls in columns.
RSpec.describe Cure::Coordinator do
  context "Process entire AWS file" do
    describe "#extract" do
      it "will extract required sections" do
        main = Cure::Launcher.new.with_csv_file(
          :pathname,
          Pathname.new("spec/cure/e2e/input/simple_translations.csv")
        ).with_config do
          transform do
            candidate column: "fav_fruit" do
              with_translation {
                replace("full").with("proc", execute: ->(val, _ctx) { val[0..3] })
              }
            end

            candidate column: "fav_fruit_2" do
              with_translation {
                replace("full", force_replace: true).with("proc", execute: ->(val, _ctx) { val[3..-1] })
              }
            end

            candidate column: "fav_fruit_3" do
              with_translation {
                replace("full", accept_translations_from: ["fav_fruit"]).with("proc", execute: ->(val, _ctx) { val[3..-1] })
              }
            end
          end

          export do
            terminal title: "Preview", limit_rows: 20
            # csv file_name: "invoice", directory: "/tmp/cure", named_range: "items"
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        # file_one = "/tmp/cure/invoice.csv"
        # expect(File.exist? file_one).to eq(true)
        #
        # expected_file = "spec/cure/e2e/output/invoice_output.csv"
        # expect(FileUtils.compare_file(file_one, expected_file)).to be_truthy
      end
    end
  end
end
