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
            with_rule :custom, { proc: Proc.new { |x| x.size > 1 } }
          end
        end
      TEMPLATE

      template_src = Cure::Dsl::DslHandler.init_from_content(doc, "test_file")
      template = template_src.generate

      @cdx = template.validator.candidates.first
    end

    it "should return a valid validation template from dsl" do
      result = @cdx.perform("hello")
      expect(result.length).to eq(0)

      result = @cdx.perform(nil)
      expect(result.length).to eq(1)
      expect(result[0]).to eq("Not null failed -> [new_column][]")
    end
  end
end
