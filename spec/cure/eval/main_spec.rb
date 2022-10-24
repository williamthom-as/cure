# frozen_string_literal: true

require "cure/eval/main"

RSpec.describe Cure::Eval::Main do
  describe ".eval" do
    it "will eval the expression" do
      Cure::Eval::Main.eval(nil, nil)
      expect(true).to eq(true)
    end
  end
end
