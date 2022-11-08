# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class RedactGenerator < BaseGenerator
      private

      # @param [object] source_value
      # @param [RowCtx] _row_ctx
      def _generate(source_value, _row_ctx)
        1.upto(length(source_value&.length || 5)).map { "X" }.join("")
      end

      def _describe
        "Will replace the length of the source string with X."
      end

    end
  end
end
