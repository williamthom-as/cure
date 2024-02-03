# frozen_string_literal: true

require "cure/strategy/imports"
require "cure/generator/imports"

# rubocop:disable Metrics/BlockLength
RSpec.describe Cure::Strategy::BaseStrategy do
  before :all do
    @base_strategy = Cure::Strategy::BaseStrategy.new({})
    @full_strategy = Cure::Strategy::FullStrategy.new({})
    @regex_strategy = Cure::Strategy::RegexStrategy.new({regex_cg: "^arn:aws:.*:(.*):.*$"})
    @match_strategy = Cure::Strategy::MatchStrategy.new({match: "match"})
    @start_strategy = Cure::Strategy::StartWithStrategy.new({match: "start"})
    @end_strategy = Cure::Strategy::EndWithStrategy.new({match: "end"})
    @append_strategy = Cure::Strategy::AppendStrategy.new({match: "append"})
    @prepend_strategy = Cure::Strategy::PrependStrategy.new({match: "prepend"})
    @contain_strategy = Cure::Strategy::ContainStrategy.new({match: "contain"})
  end

  describe "#describe" do
    it "should describe the base strategy" do
      expect(@full_strategy.describe).to eq("Full replacement of source value with generated value.")
      expect(@regex_strategy.describe).to eq(
        "Matching on '^arn:aws:.*:(.*):.*$'. [Note: If the regex does not match, or has no capture group, no substitution is made.]"
      )
      expect(@match_strategy.describe).to eq("Match replacement will look for the presence of 'match', and replace that value. [Note: If the value does not include 'match', no substitution is made.]")
      expect(@start_strategy.describe).to eq("Start with replacement will look for 'start'. It will do a full replacement. [Note: If the value does not include 'start', no substitution is made.]")
      expect(@end_strategy.describe).to eq("End with replacement will look for 'end'. It will do a full replacement. [Note: If the value does not include 'end', no substitution is made.]")
      expect(@append_strategy.describe).to eq("Append generated value to the end of source value")
      expect(@prepend_strategy.describe).to eq("Prepend generated value to the end of source value")
      expect(@contain_strategy.describe).to eq("Replacing matched value on 'contain') [Note: If the value does not include 'contain', no substitution is made.]")
    end
  end

  describe "#new" do
    it "should load options" do
      opts = {regex_cg: "^arn:aws:.*:(.*):.*$"}
      strategy = Cure::Strategy::RegexStrategy.new(opts)
      strategy.clear_history

      expect(strategy.history.table_count).to eq(0)
      expect(strategy.params.regex_cg).to eq(opts[:regex_cg])
    end
  end

  describe "#extract" do
    it "should extract valid value, and use history for similarity" do
      id = "arn:aws:kms:ap-southeast-2:111111111111:key/22222222-2222-2222-2222-222222222222"
      result = @regex_strategy.extract(id, nil, Cure::Generator::NumberGenerator.new({length: 10}))
      expect(result).to_not eq(id)

      all_values = @regex_strategy.history.all_values

      expect(all_values.first[:source_value]).to eq("111111111111")
      expect(all_values.first[:value]).to be_truthy

      result_two = @full_strategy.extract("111111111111", nil, Cure::Generator::NumberGenerator.new({length: 10}))
      expect(result_two == all_values.first[:value]).to be_truthy

      result_three = @match_strategy.extract("match", nil, Cure::Generator::StaticGenerator.new({value: "replace"}))
      expect(result_three).to eq("replace")

      result_four = @start_strategy.extract("start_with", nil, Cure::Generator::StaticGenerator.new({value: "replace"}))
      expect(result_four).to eq("replace")

      result_five = @start_strategy.extract("no_match", nil, Cure::Generator::NumberGenerator.new({length: 10}))
      expect(result_five).to eq(nil)

      result_six = @end_strategy.extract("with_end", nil, Cure::Generator::StaticGenerator.new({value: "replace"}))
      expect(result_six).to eq("replace")

      result_seven = @end_strategy.extract("no_match", nil, Cure::Generator::StaticGenerator.new({value: "replace"}))
      expect(result_seven).to eq(nil)

      result_eight = @append_strategy.extract("after-this", nil, Cure::Generator::StaticGenerator.new({value: "-after"}))
      expect(result_eight).to eq("after-this-after")

      result_nine = @contain_strategy.extract("hidden-contain-this", nil, Cure::Generator::StaticGenerator.new({value: "replace"}))
      expect(result_nine).to eq("hidden-replace-this")

      result_ten = @prepend_strategy.extract("before-this", nil, Cure::Generator::StaticGenerator.new({value: "front-"}))
      expect(result_ten).to eq("front-before-this")
    end
  end

  describe "#_retrieve_value" do
    it "should raise if called on base class" do
      expect { @base_strategy.extract("abc", nil, Cure::Generator::RedactGenerator.new) }.to raise_error(NotImplementedError)
    end
  end

  describe "#_replace_value" do
    it "should raise if called on base class" do
      expect { @base_strategy.send(:_replace_value, "a", "b") }.to raise_error(NotImplementedError)
    end
  end

  describe "replace_partial" do
    it "should replace the start if partial is set" do
      start_strategy = Cure::Strategy::StartWithStrategy.new({match: "my_val_", replace_partial: true})
      expect(start_strategy.params.valid?).to eq(true)

      result = start_strategy.extract("my_val_replace_me", nil, Cure::Generator::NumberGenerator.new({length: 10}))

      expect(result.length).to eq(10 + "my_val_".length)
      expect(result.start_with?("my_val_")).to be_truthy
    end

    it "should replace the end if partial is set" do
      end_strategy = Cure::Strategy::EndWithStrategy.new({match: "_my_val", replace_partial: true})
      result = end_strategy.extract("replace_me_my_val", nil, Cure::Generator::NumberGenerator.new({length: 10}))

      expect(result.length).to eq(10 + "my_val_".length)
      expect(result.end_with?("_my_val")).to be_truthy
    end

    it "should replace the entire if no partial is set" do
      end_strategy = Cure::Strategy::EndWithStrategy.new({match: "_my_val", replace_partial: "false"})
      result = end_strategy.extract("replace_me_my_val", nil, Cure::Generator::NumberGenerator.new({length: 10}))

      expect(result.length).to eq(10)
      expect(result.end_with?("_my_val")).to be_falsey

      end_strategy_one = Cure::Strategy::EndWithStrategy.new({match: "_my_val"})
      result1 = end_strategy_one.extract("replace_me_my_val", nil, Cure::Generator::NumberGenerator.new({length: 10}))

      expect(result1.length).to eq(10)
      expect(result1.end_with?("_my_val")).to be_falsey
    end

    it "should run" do
      strat = Cure::Strategy::SplitStrategy.new({token: ":", index: 4})
      result = strat.extract("arn:aws:apigateway:us-east-1::/restapis/abcdef/stages/dev",
                             nil,
                             Cure::Generator::NumberGenerator.new({length: 10}))
      expect(result).to eq("arn:aws:apigateway:us-east-1::/restapis/abcdef/stages/dev")
      result_two = strat.extract("arn:aws:apigateway:us-east-1:abcdef:/restapis/abcdef/stages/dev",
                                 nil,
                                 Cure::Generator::RedactGenerator.new({length: 3}))
      expect(result_two).to eq("arn:aws:apigateway:us-east-1:xxx:/restapis/abcdef/stages/dev")
    end
  end
end
# rubocop:enable Metrics/BlockLength
