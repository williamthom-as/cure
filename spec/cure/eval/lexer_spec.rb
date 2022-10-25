# frozen_string_literal: true

require "cure/eval/lexer"

RSpec.describe Cure::Eval::Lexer do
  describe ".lex" do
    it "will ignore white space" do
      tokens = described_class.lex(" 12 +   3")
      puts tokens
      # expect(tokens).to eq(%w[1 2 + 3])
    end


    it "will find identity" do
      tokens = described_class.lex("identity + 123e1")
      puts tokens
      # expect(tokens).to eq(%w[identity + 123e1])
    end
  end
end

RSpec.describe Cure::Eval::Scanner do
  describe "#identifier_start?" do

    it "will return true if identity" do
      result = described_class.new("text").send(:identifier_start?, "a")
      expect(result).to be_truthy
    end

    it "will return false if not identity" do
      result = described_class.new("text").send(:identifier_start?, "*")
      expect(result).to be_falsey
    end
  end
end
