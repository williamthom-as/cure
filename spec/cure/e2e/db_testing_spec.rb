# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"
require "cure/log"

require "fileutils"

class RowCollector

  attr_reader :rows

  def initialize; @rows = {} end

  def call(row, named_range)
    @rows[named_range] ||= []
    @rows[named_range] << row
  end
end

# This tests using the same DB for variables.
RSpec.describe Cure::Coordinator do
  context "process from file contents" do
    describe "#extract" do
      it "will keep the same variables for name translation between two files" do
        database_name = "/tmp/db_testing_#{SecureRandom.uuid}.db"

        row_collector = RowCollector.new

        Dir.glob("spec/cure/e2e/input/db_testing/*.csv").each do |f|
          handler = Cure.init do
            named_range = File.basename(f, File.extname(f))

            sources { csv :pathname, Pathname.new(f) }

            extract { named_range name: named_range }

            database {
              persisted file_path: database_name
              allow_existing_table true
              drop_table_on_initialise false
              trunc_table_on_initialise false
              trunc_translations_table_on_initialise false
            }

            transform do
              candidate column: "Name", named_range: named_range do
                with_translation { replace("full").with("faker", module: "Name", method: "first_name") }
              end
            end

            export do
              terminal title: "Exported", limit_rows: 5, named_range: named_range
              yield_row proc: row_collector, named_range: named_range
            end
          end

          handler.run_export
        end

        # Clean up temp DB
        File.delete(database_name)

        colors_names = row_collector.rows["colors"].map { _1[:Name] }
        dessert_rows = row_collector.rows["dessert"].map { _1[:Name] }

        # We are testing if the existing variables are used when processing a different file.
        expect(colors_names == dessert_rows).to eq(true)
      end

      it "will join the content of two of the same files to the same db table" do
        database_name = "/tmp/db_testing_#{SecureRandom.uuid}.db"

        row_collector = RowCollector.new

        Dir.glob("spec/cure/e2e/input/db_testing/dessert*").each do |f|
          handler = Cure.init do
            file_name = File.basename(f, File.extname(f))

            sources { csv :pathname, Pathname.new(f) }

            database {
              persisted file_path: database_name
              allow_existing_table true
              drop_table_on_initialise false
              trunc_table_on_initialise false
              trunc_translations_table_on_initialise false
            }

            transform do
              candidate column: "Name" do
                with_translation { replace("full").with("faker", module: "Name", method: "first_name") }
              end
            end

            export do
              if file_name == "dessert_two"
                terminal title: "Exported", limit_rows: 20
                yield_row proc: row_collector
              end
            end
          end

          handler.run_export
        end

        # Clean up temp DB
        File.delete(database_name)

        # We are testing if the existing variables are used when processing a different file.
        expect(row_collector.rows["_default"].size).to eq(10)
      end
    end
  end
end
