# frozen_string_literal: true

require "cure/strategy/base"
require "cure/generator/base"

RSpec.describe Cure::Strategy::RegexStrategy do

  before :all do
    @regex_strategy = Cure::Strategy::RegexStrategy.new({"regex_cg" => "^arn:aws:.*:(.*):.*$"})
    @full_strategy = Cure::Strategy::FullStrategy.new({})
    @base_strategy = Cure::Strategy::Base.new({})
  end

  describe "#new" do
    it "should load options" do
      opts = {"regex_cg" => "^arn:aws:.*:(.*):.*$"}
      strategy = Cure::Strategy::RegexStrategy.new(opts)
      expect(strategy.history).to eq({})
      expect(strategy.options).to eq(opts)
    end
  end

  describe "#extract" do
    it "should extract valid value, and use history for similarity" do
      id = "arn:aws:kms:ap-southeast-2:111111111111:key/22222222-2222-2222-2222-222222222222"
      result = @regex_strategy.extract(id, Cure::Generator::NumberGenerator.new({"length" => 10}))
      result_two = @full_strategy.extract("111111111111", Cure::Generator::NumberGenerator.new({"length" => 10}))

      expect(result).to_not eq(id)
      expect(@regex_strategy.history.keys).to eq(["111111111111"])
      expect(result.include?(@regex_strategy.history&.values&.first)).to be_truthy

      expect(result_two.include?(@regex_strategy.history&.values&.first)).to be_truthy
    end
  end

  describe "#_retrieve_value" do
    it "should raise if called on base class" do
      expect { @base_strategy.extract("abc", Cure::Generator::RedactGenerator.new) }.to raise_error(NotImplementedError)
    end
  end
end
