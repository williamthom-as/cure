# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"
require "cure/log"

require "fileutils"

# This tests whitelisting columns, transforms (with placeholders, and no matches), nulls in columns.
RSpec.describe Cure::Coordinator do
  context "Process entire AWS file" do
    describe "#extract" do
      it "will extract required sections" do
        main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/e2e/input/aws_billing_input.csv"))
        main.with_config do
          build do
            candidate do
              whitelist options: {
                columns: %w[
                  bill/BillingEntity
                  bill/PayerAccountId
                  bill/BillingPeriodStartDate
                  bill/BillingPeriodEndDate
                  lineItem/UsageAccountId
                  lineItem/LineItemType
                  lineItem/UsageStartDate
                  lineItem/UsageEndDate
                  lineItem/UsageType
                  lineItem/ResourceId
                  lineItem/ProductCode
                  lineItem/UsageAmount
                  lineItem/CurrencyCode
                ]
              }
            end
          end

          rot13_proc = proc { |source, _ctx|
            source.gsub(/[^a-zA-Z0-9]/, '').tr('A-Za-z', 'N-ZA-Mn-za-m')
          }

          transform do
            candidate column: "bill/PayerAccountId" do
              with_translation { replace("full").with("placeholder", name: :account_number) }
            end

            candidate column: "lineItem/UsageAccountId" do
              with_translation { replace("full").with("number", length: 10) }
            end

            candidate column: "lineItem/ResourceId", options: {ignore_empty: true} do
              # If there is a match (i-[my-group]), replace just the match group with a hex string of 10 length
              with_translation { replace("regex", regex_cg: "^i-(.*)").with("proc", execute: rot13_proc) }

              # If the string contains the account number, replace with the account_number placeholder.
              with_translation { replace("contain", match: "1234567890").with("placeholder", name: :account_number) }

              # If no match is found, replace the whole match with a prefix hidden_ along with a random 10 char hex string
              if_no_match { replace("full").with("proc", execute: rot13_proc) }
            end

            # Hardcoded values that we may wish to reference
            place_holders({account_number: 987_654_321})
          end

          export do
            terminal title: "Preview", limit_rows: 20
            csv file_name: "aws", directory: "/tmp/cure"
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        file_one = "/tmp/cure/aws.csv"
        expect(File.exist? file_one).to eq(true)

        expected_file = "spec/cure/e2e/output/aws_billing_output.csv"
        expect(FileUtils.compare_file(file_one, expected_file)).to be_truthy
      end
    end
  end
end
