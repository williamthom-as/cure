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
        main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/purchase_order.csv"))
        main.with_config do
          extract do
            named_range name: "items", at: "A4:G10", headers: "A4:F4"
            variable name: "invoice_date", at: "B1"
            variable name: "invoice_total", at: "G12"
          end

          build do
            candidate column: "purchase_date", named_range: "items" do
              add options: {}
            end

            candidate column: "percentage_of_total", named_range: "items" do
              add options: {}
            end

            candidate column: "code", named_range: "items" do
              add options: {}
            end
          end

          query do
            with named_range: "items", query: <<-SQL
              SELECT
                sku, 
                code, 
                item, 
                vendor,
                cost_per_kilo, 
                amount_in_kilo, 
                total_cost, 
                purchase_date,
                percentage_of_total
              FROM items
            SQL
          end

          rot13_proc = proc { |source, _ctx|
            source.gsub(/[^a-zA-Z0-9]/, '').tr('A-Za-z', 'N-ZA-Mn-za-m')
          }

          ctx_rot13_proc = proc { |_source, ctx|
            ctx.row[:item].gsub(/[^a-zA-Z0-9]/, '').tr('A-Za-z', 'N-ZA-Mn-za-m').upcase[0..2]
          }

          transform do
            candidate named_range: "items", column: "item" do
              with_translation { replace("match", match: "oarnge").with("static", value: "orange") }
            end

            candidate named_range: "items", column: "sku" do
              with_translation { replace("full").with("proc", execute: rot13_proc) }
            end

            candidate named_range: "items", column: "code" do
              with_translation { replace("full", force_replace: true).with("static", value: "FRUIT-") }
              with_translation { replace("append", force_replace: true).with("proc", execute: ctx_rot13_proc) }
            end

            candidate named_range: "items", column: "purchase_date" do
              with_translation { replace("full").with("variable", name: "invoice_date") }
            end

            candidate named_range: "items", column: "percentage_of_total" do
              with_translation { replace("full", force_replace: true).with("variable", name: "invoice_total") }
              with_translation { replace("full", force_replace: true).with("proc", execute: proc { |source, ctx|
                "#{((ctx.row[:total_cost].to_f / source.to_f) * 100).round(2)}%" }
              )}
            end

            candidate named_range: "items", column: "vendor" do
              with_translation { replace("full").with("proc", execute: rot13_proc) }
            end
          end

          export do
            terminal title: "Preview", limit_rows: 20, named_range: "items"
            csv file_name: "invoice", directory: "/tmp/cure", named_range: "items"
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        file_one = "/tmp/cure/invoice.csv"
        expect(File.exist? file_one).to eq(true)

        expected_file = "spec/cure/e2e/output/invoice_output.csv"
        expect(FileUtils.compare_file(file_one, expected_file)).to be_truthy
      end
    end
  end
end
