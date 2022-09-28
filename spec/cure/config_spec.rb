# frozen_string_literal: true

require "json"
require "cure/config"

RSpec.describe Cure::Main do
  describe "#init" do
    it "should set up the main service" do
      source_file_loc = "../../spec/cure/test_files/test_csv_file.csv"
      template_file_loc = "../../spec/cure/test_files/test_template.json"
      tmp_location = "/tmp/cure"

      main = Cure::Main.init_from_file(template_file_loc, source_file_loc, tmp_location)
      expect(main.is_initialised).to eq(true)
      expect(main.transformer).to_not be(nil)

      config = main.config
      expect(config.source_file_location).to eq(source_file_loc)
      expect(config.template.class).to eq(Cure::Template)
      expect(config.output_dir).to eq(tmp_location)
    end
  end

  describe "#build_ctx" do
    it "should build ctx" do
      source_file_loc = "../../spec/cure/test_files/test_csv_file.csv"
      template_file_loc = "../../spec/cure/test_files/test_template.json"
      tmp_location = "/tmp/cure"

      main = Cure::Main.init_from_file(template_file_loc, source_file_loc, tmp_location)
      ctx = main.run_transform["default"]

      expect(ctx.column_headers).to eq({"test_column" => 0, "test_column2" => 1})
      expect(ctx.row_count).to eq(4)
    end
  end
end
