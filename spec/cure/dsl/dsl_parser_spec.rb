# frozen_string_literal: true

RSpec.describe Cure::Dsl::Template do
  describe "#create" do
    it "should return a template from dsl" do
      doc = <<-TEMPLATE
        csv file: "location", encoding: "utf-8"

        extraction("test") do
          named_ranges do
            section name: "section_1", at: "B2:G6"
            section name: "section_2", at: "C2:H6"
          end

          # variables do
          #   variable name: "new_field", location: "A16"
          # end
        end
      TEMPLATE

      template = described_class.new(doc, "test_file")
      result = template.generate

      # expect(result).to_not be_nil
    end
  end
end
