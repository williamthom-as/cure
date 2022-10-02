# frozen_string_literal: true

require "json"
require "cure/coordinator"

RSpec.describe Cure::Coordinator do
  before :all do
    @source_file_loc = "../../../spec/cure/test_files/test_csv_file.csv"
    template_file_loc = "../../../spec/cure/test_files/test_template.json"

    Cure::Main.init_from_file(template_file_loc, @source_file_loc, "/tmp")
    @coordinator = Cure::Coordinator.new
  end

  describe "#extract" do
    it "will extract required sections" do
      result = @coordinator.send(:extract)
      expect(result.variables.keys).to be_empty
      expect(result.content.length).to be(1)

      csv = result.content.first

      expect(csv["name"]).to be("default")
      expect(csv["content"].rows.length).to be(3)
      expect(csv["content"].column_headers.keys).to eq(%w[test_column test_column2])
      expect(csv["content"].rows[0]).to eq(%w[abc def])
      expect(csv["content"].rows[1]).to eq(%w[abc def])
      expect(csv["content"].rows[2]).to eq(%w[abc def])
    end
  end
end
