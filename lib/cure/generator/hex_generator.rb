# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class HexGenerator < BaseGenerator
      private

      # @param [Object] _source_value
      # @param [RowCtx] _row_ctx
      def _generate(_source_value, _row_ctx)
        1.upto(length(rand(0..9))).map { rand(0..15).to_s(16) }.join("")
      end

      def _describe
        "Will create a random list of hex values matching the length of the source string."
      end
    end
  end
end
