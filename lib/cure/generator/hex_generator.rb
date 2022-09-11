# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class HexGenerator < BaseGenerator
      private

      # @param [Object] _source_value
      def _generate(_source_value)
        1.upto(length(rand(0..9))).map { rand(0..15).to_s(16) }.join("")
      end
    end
  end
end
