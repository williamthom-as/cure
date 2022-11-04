# frozen_string_literal: true

require "cure/eval/lexer"

RSpec.describe Cure::Eval::Lexer do
  describe ".lex" do
    it "will ignore white space" do
      tokens = described_class.lex(" 12 +   3")
      puts tokens
      # expect(tokens.map { |x| x.text }).to eq(%w[1 2 + 3])
    end


    it "will find scientific notation" do
      tokens = described_class.lex("identity 123e1")
      puts tokens
      expect(tokens.map { |x| x.text }).to eq(["identity", 1230.0])
    end

    it "will find decimals" do
      tokens = described_class.lex("1.23 .122")
      puts tokens
      expect(tokens.map { |x| x.text }).to eq([1.23, 0.122])
    end

    it "will find characters" do
      tokens = described_class.lex("(.) (.)")
      puts tokens
      expect(tokens.map { |x| x.text }).to eq(%w[( . ) ( . )])
    end

    it "will find strings" do
      tokens = described_class.lex("'test''test1'")
      puts tokens
      expect(tokens.map { |x| x.text }).to eq(%w[test test1])
    end

    it "will find operators" do
      tokens = described_class.lex("- +")
      puts tokens
      expect(tokens.map { |x| x.text }).to eq(%w[- +])
    end

    it "will find complex operators" do
      tokens = described_class.lex("<= >= == > && &")
      puts tokens
      expect(tokens.map { |x| x.text }).to eq(%w[<= >= == > && &])
    end

    it "will find complex operators" do
      tokens = described_class.lex("| ||")
      puts tokens
      expect(tokens.map { |x| x.text }).to eq(%w[| ||])
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
