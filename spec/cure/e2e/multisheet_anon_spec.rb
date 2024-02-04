# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"
require "cure/log"

# This tests joining multi sheets, anonymised reference and metadata exports
RSpec.describe Cure::Coordinator do
  context "Process and chunk a simple csv file" do
    describe "#extract" do
      it "will extract required sections" do
        main = Cure::Launcher.new
        main.with_config do
          CUSTOMERS_SHEET = "names_sheet"
          ORDERS_SHEET = "orders_sheet"
          PAYMENTS_SHEET = "payments_sheet"

          sources do
            csv :pathname, Pathname.new("spec/cure/e2e/input/multisheet/customers.csv"), ref_name: CUSTOMERS_SHEET
            csv :pathname, Pathname.new("spec/cure/e2e/input/multisheet/orders.csv"), ref_name: ORDERS_SHEET
            csv :pathname, Pathname.new("spec/cure/e2e/input/multisheet/payments.csv"), ref_name: PAYMENTS_SHEET
          end

          extract do
            named_range name: "customers", ref_name: CUSTOMERS_SHEET
            named_range name: "orders", ref_name: ORDERS_SHEET
            named_range name: "payments", ref_name: PAYMENTS_SHEET
          end

          query do
            with named_range: "customers", query: <<-SQL
              SELECT
                  c.customer_id,
                  c.name,
                  o.product,
                  o.quantity,
                  SUM(p.amount) as total_amount,
                  MAX(p.date) as payment_date
              FROM
                  customers c
              LEFT JOIN orders o ON c.customer_id = o.customer_id
              LEFT JOIN payments p ON c.customer_id = p.customer_id
              GROUP BY
                c.customer_id,
                c.name,
                c.email,
                o.order_id,
                o.product,
                o.quantity;
            SQL

            with named_range: "translations", query: <<-SQL
              SELECT
                  value as original,
                  source_value as translated
              FROM
                  translations
            SQL
          end

          transform do
            candidate named_range: "customers", column: "name" do
              with_translation { replace("full").with("proc", execute: proc { |source, _ctx|
                source.gsub(/[^a-zA-Z0-9]/, '').tr('A-Za-z', 'N-ZA-Mn-za-m')
              })
            }
            end
          end

          export do
            terminal title: "Exported", limit_rows: 10, named_range: "customers"
            terminal title: "Lookup", limit_rows: 10, named_range: "translations"

            csv file_name: "multisheet_data", directory: "/tmp/cure", named_range: "customers"
            csv file_name: "multisheet_lookup", directory: "/tmp/cure", named_range: "translations"
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        file_one = "/tmp/cure/multisheet_data.csv"
        expect(File.exist? file_one).to eq(true)

        file_two = "/tmp/cure/multisheet_lookup.csv"
        expect(File.exist? file_two).to eq(true)

        expected_file = "spec/cure/e2e/output/multisheet/multisheet_data.csv"
        expect(FileUtils.compare_file(file_one, expected_file)).to be_truthy

        expected_file_two = "spec/cure/e2e/output/multisheet/multisheet_lookup.csv"
        expect(FileUtils.compare_file(file_two, expected_file_two)).to be_truthy
      end
    end
  end
end
