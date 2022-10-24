# frozen_string_literal: true

require "cure/eval/lexer"

RSpec.describe Cure::Eval::Lexer do
  describe ".lex" do
    it "will ignore white space" do
      tokens = described_class.lex(" 44 +   3")
      puts tokens
      expect(tokens).to eq(%w[4 4 + 3])
    end
  end
end
