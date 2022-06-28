# frozen_string_literal: true

require "cure/strategy/base"
require "cure/generator/base"

RSpec.describe Cure::Strategy::Base do

  before :all do
    @base_strategy = Cure::Strategy::Base.new({})
    @full_strategy = Cure::Strategy::FullStrategy.new({})
    @regex_strategy = Cure::Strategy::RegexStrategy.new({"regex_cg" => "^arn:aws:.*:(.*):.*$"})
    @match_strategy = Cure::Strategy::MatchStrategy.new({"match" => "my_val"})
    @start_strategy = Cure::Strategy::StartWithStrategy.new({"match" => "my_val"})
    @end_strategy = Cure::Strategy::EndWithStrategy.new({"match" => "my_val"})
  end

  describe "#new" do
    it "should load options" do
      opts = {"regex_cg" => "^arn:aws:.*:(.*):.*$"}
      strategy = Cure::Strategy::RegexStrategy.new(opts)
      strategy.clear_history

      expect(strategy.history).to eq({})
      expect(strategy.options).to eq(opts)
    end
  end

  describe "#extract" do
    it "should extract valid value, and use history for similarity" do
      id = "arn:aws:kms:ap-southeast-2:111111111111:key/22222222-2222-2222-2222-222222222222"
      result = @regex_strategy.extract(id, Cure::Generator::NumberGenerator.new({"length" => 10}))

      expect(result).to_not eq(id)
      expect(@regex_strategy.history.keys).to eq(["111111111111"])
      expect(result.include?(@regex_strategy.history&.values&.first)).to be_truthy

      result_two = @full_strategy.extract("111111111111", Cure::Generator::NumberGenerator.new({"length" => 10}))
      expect(result_two.include?(@regex_strategy.history&.values&.first)).to be_truthy

      result_three = @match_strategy.extract("my_val", Cure::Generator::NumberGenerator.new({"length" => 10}))
      expect(result_three).to_not eq("my_val")

      result_four = @start_strategy.extract("my_val_test", Cure::Generator::NumberGenerator.new({"length" => 10}))
      expect(result_four).to_not eq("my_val")

      result_five = @start_strategy.extract("test_my_val_test", Cure::Generator::NumberGenerator.new({"length" => 10}))
      expect(result_five).to eq(nil)

      result_six = @end_strategy.extract("test_my_val", Cure::Generator::NumberGenerator.new({"length" => 10}))
      expect(result_six).to_not eq("my_val")

      result_seven = @end_strategy.extract("test_my_val_test", Cure::Generator::NumberGenerator.new({"length" => 10}))
      expect(result_seven).to eq(nil)
    end
  end

  describe "#_retrieve_value" do
    it "should raise if called on base class" do
      expect { @base_strategy.extract("abc", Cure::Generator::RedactGenerator.new) }.to raise_error(NotImplementedError)
    end
  end

  describe "#_replace_value" do
    it "should raise if called on base class" do
      expect { @base_strategy.send(:_replace_value, "a", "b") }.to raise_error(NotImplementedError)
    end
  end

  describe "replace_partial" do
    it "should replace the start if partial is set" do
      start_strategy = Cure::Strategy::StartWithStrategy.new({"match" => "my_val_", "replace_partial" => true})
      result = start_strategy.extract("my_val_replace_me", Cure::Generator::NumberGenerator.new({"length" => 10}))

      expect(result.length).to eq(10 + "my_val_".length)
      expect(result.start_with?("my_val_")).to be_truthy
    end

    it "should replace the end if partial is set" do
      end_strategy = Cure::Strategy::EndWithStrategy.new({"match" => "_my_val", "replace_partial" => true})
      result = end_strategy.extract("replace_me_my_val", Cure::Generator::NumberGenerator.new({"length" => 10}))

      expect(result.length).to eq(10 + "my_val_".length)
      expect(result.end_with?("_my_val")).to be_truthy
    end

    it "should replace the entire if no partial is set" do
      end_strategy = Cure::Strategy::EndWithStrategy.new({"match" => "_my_val", "replace_partial" => "false"})
      result = end_strategy.extract("replace_me_my_val", Cure::Generator::NumberGenerator.new({"length" => 10}))

      expect(result.length).to eq(10)
      expect(result.end_with?("_my_val")).to be_falsey

      end_strategy_one = Cure::Strategy::EndWithStrategy.new({"match" => "_my_val"})
      result1 = end_strategy_one.extract("replace_me_my_val", Cure::Generator::NumberGenerator.new({"length" => 10}))

      expect(result1.length).to eq(10)
      expect(result1.end_with?("_my_val")).to be_falsey
    end

    it "should run" do
      strat = Cure::Strategy::RegexStrategy.new({"regex_cg" => "^arn:aws:.*:(.*):.*$"})
      result = strat.extract("arn:aws:apigateway:us-east-1::/restapis/bdwt2mrwr7/stages/dev", Cure::Generator::NumberGenerator.new({"length" => 10}))
      puts result
    end

  end
end
