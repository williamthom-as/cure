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

  # describe "#init_from_file" do
  #   it "should set up the main service" do
  #     source_file_loc = "spec/cure/test_files/test_csv_file.csv"
  #     template = {
  #       "transformations" => {
  #         "candidates" => [{
  #           "column" => "my_col",
  #           "translations" => [{}]
  #         }],
  #         "placeholders" => []
  #       }
  #     }
  #
  #     main = Cure::Launcher.new
  #                      .with_csv_file(:pathname, Pathname.new(source_file_loc))
  #                      .with_template(:template, template)
  #                      .setup
  #
  #     config = main.config
  #     expect(config.template.class).to eq(Cure::Template)
  #   end
  # end

  pending describe "#run_export" do # fix export then redo
    it "should run export" do
      main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new("spec/cure/test_files/test_csv_file.csv"))
      main.with_config do
        transform do
          candidate column: "test_column" do
            with_translation { replace("full").with("number", length: 12)}
          end
        end

        export do
          csv named_range: "_default", file: "/tmp/cure/_default.csv"
        end
      end
      main.setup

      main.with_temp_dir("/tmp/cure") do
        main.run_export
        expect(Dir["/tmp/cure/*.csv"].length.positive?).to be_truthy
      end

      expect(Dir["/tmp/cure/*.csv"].length.positive?).to be_falsey
    end
  end
end
# rubocop:enable Metrics/BlockLength
