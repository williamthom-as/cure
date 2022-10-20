# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class RowGenerator < BaseGenerator
      private

      # @param [Object] source_value
      # @param [RowCtx] row_ctx
      def _generate(source_value, row_ctx)
        puts row_ctx

        source_value
      end

      def columns
        @opts.fetch("columns", [])
      end
    end
  end
end
