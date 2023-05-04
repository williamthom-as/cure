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
        main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/test_csv_file.csv"))
        main.with_config do
          transform do
            candidate column: "test_column" do
              with_translation { replace("full").with("number", length: 12)}
            end
          end

          export do
            chunk_csv file_name_prefix: "default", directory: "/tmp/cure", chunk_size: 2
          end
        end

        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        file_one = "/tmp/cure/1-default.csv"
        expect(File.exist? file_one).to eq(true)

        file_one_contents = extract_contents(file_one)
        expect(file_one_contents.size).to eq(3)
        expect(file_one_contents[0].size).to eq(2)
        expect(file_one_contents[0]).to eq(%w[test_column test_column2])

        expect(file_one_contents[1].size).to eq(2)
        expect(file_one_contents[1][0].length).to eq(12)
        expect(file_one_contents[1][1]).to eq("def")

        expect(file_one_contents[2].size).to eq(2)
        expect(file_one_contents[2][0].length).to eq(12)
        expect(file_one_contents[2][1]).to eq("def")

        file_two = "/tmp/cure/2-default.csv"
        expect(File.exist? file_two).to eq(true)

        file_two_contents = extract_contents(file_two)
        expect(file_two_contents.size).to eq(2)
        expect(file_two_contents[0].size).to eq(2)
        expect(file_two_contents[0]).to eq(%w[test_column test_column2])

        expect(file_two_contents[1].size).to eq(2)
        expect(file_two_contents[1][0].length).to eq(12)
        expect(file_two_contents[1][1]).to eq("def")
      end
    end
  end
end
