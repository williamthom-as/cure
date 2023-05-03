# frozen_string_literal: true

require "cure/validator/candidate"
require "cure/dsl/template"

RSpec.describe Cure::Validator::Candidate do
  describe "#perform" do
    before :all do
      doc = <<-TEMPLATE
        validate do
          candidate column: "new_column", named_range: "section_1", options: { fail_on_error: false } do
            with_rule :not_null
            with_rule :length, { min: 0, max: 5 }
            with_rule :custom, { proc: Proc.new { |x| x.size < 6 } }
          end
        end
      TEMPLATE

      template_src = Cure::Dsl::DslHandler.init_from_content(doc, "test_file")
      template = template_src.generate
      @cdx = template.validator.candidates.first
    end

    it "should return valid for valid" do
      result = @cdx.perform("hello")
      expect(result.length).to eq(0)
    end

    it "should return invalid for invalid" do
      result = @cdx.perform(nil)
      expect(result.length).to eq(1)
      expect(result[0]).to eq("Not null failed -> [new_column][]")

      result1 = @cdx.perform("hellohellohellohellohello")
      expect(result1.length).to eq(2)
      expect(result1).to eq([
        "Length [Min: 5, Max: 5] failed -> [new_column][hellohellohellohellohello]",
        "Custom failed -> [new_column][hellohellohellohellohello]"]
      )
    end
  end
end
