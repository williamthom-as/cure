# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class NumberGenerator < BaseGenerator
      private

      # @param [Object] _source_value
      # @param [RowCtx] _row_ctx
      def _generate(_source_value, _row_ctx)
        1.upto(length(rand(0..9))).map { rand(1..9) }.join("").to_i
      end
    end
  end
end
