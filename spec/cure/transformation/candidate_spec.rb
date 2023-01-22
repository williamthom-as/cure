# frozen_string_literal: true

require "cure/transformation/candidate"
require "cure/generator/base_generator"
require "cure/strategy/base_strategy"
require "cure/dsl/transformations"

RSpec.describe Cure::Transformation::Candidate do # rubocop:disable Metrics/BlockLength
  describe "#new" do
    it "should load a candidate" do
      dsl_candidate = Cure::Dsl::Transformations.new
      dsl_candidate.candidate(column: "bill/PayerAccountId") do
        with_translation { replace("full").with("number", length: 12) }
        with_translation { replace("full").with("guid", length: 24) }
      end

      candidate = dsl_candidate.candidates.first
      expect(candidate.translations.first.class).to eq(Cure::Transformation::Translation)
      expect(candidate.translations.first.strategy.class).to eq(Cure::Strategy::FullStrategy)
      expect(candidate.translations.first.generator.class).to eq(Cure::Generator::NumberGenerator)
    end

    it "it should look up in history if it exists" do
      dsl_candidate = Cure::Dsl::Transformations.new
      dsl_candidate.candidate(column: "bill/PayerAccountId") do
        with_translation { replace("full").with("number", length: 12) }
        with_translation { replace("full").with("guid", length: 24) }
      end

      candidate = dsl_candidate.candidates.first
      val = candidate.perform("abc", nil)
      val_two = candidate.perform("abc", nil)
      expect(val).to eq(val_two)
    end

    it "strategy length should match the options" do
      dsl_candidate = Cure::Dsl::Transformations.new
      dsl_candidate.candidate(column: "bill/PayerAccountId") do
        with_translation { replace("full").with("number", length: 12) }
        with_translation { replace("full").with("guid", length: 24) }
      end

      candidate = dsl_candidate.candidates.first
      val = candidate.perform("xxk", nil)
      expect(val.to_s.length).to eq(36)
    end
  end

  describe "#extract" do
    it "it should look up in history if it exists" do
      dsl_candidate = Cure::Dsl::Transformations.new
      dsl_candidate.candidate(column: "lineItem/ResourceId") do
        with_translation { replace("regex", regex_cg: "^arn:aws:.*:(.*):.*$").with("number", length: 12) }
        with_translation { replace("regex", regex_cg: "^.*:.*\/(.*)$").with("guid", length: 48) }
        with_translation { replace("regex", regex_cg: "^i-(.*)").with("number", length: 12) }
        if_no_match { replace("full").with("guid", length: 24) }
      end

      candidate = dsl_candidate.candidates.first

      val = candidate.perform("arn:aws:kms:ap-southeast-2:111111111111:key/e8192ac9-1111-1111-1111-42f9b7e18937", nil)
      val_two = candidate.perform("arn:aws:kms:ap-southeast-2:111111111111:key/e8192ac9-1111-1111-1111-42f9b7e18937", nil)
      val_three = candidate.perform("i-11111111", nil)
      val_four = candidate.perform("ABCNOMATCHFORME", nil)

      expect(val).to eq(val_two)
      expect(val_three).to_not eq("i-11111111")
      expect(val_four.length).to eq(36)
    end
  end
end
