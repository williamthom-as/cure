# frozen_string_literal: true

require "json"
require "cure/coordinator"
require "cure/database"
require "cure/log"

RSpec.describe Cure::Coordinator do
  context "Process entire AWS file" do
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
            csv file_name: "default", directory: "/tmp/cure"
          end
        end
        main.setup

        coordinator = Cure::Coordinator.new
        coordinator.process

        expect(File.exist? "/tmp/cure/default.csv").to eq(true)
      end
    end
  end
end
