# frozen_string_literal: true

require "json"
require "cure/config"

# rubocop:disable Metrics/BlockLength
RSpec.describe Cure::Launcher do
  describe "#init" do
    it "should set up the main service" do
      main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/test_csv_file.csv"))
      main.with_config do
        transform do
          candidate column: "test_column" do
            with_translation { replace("full").with("number", length: 12)}
          end
        end
      end
      main.setup

      config = main.config
      expect(config.template.class).to eq(Cure::Dsl::Template)
    end
  end
end
# rubocop:enable Metrics/BlockLength
