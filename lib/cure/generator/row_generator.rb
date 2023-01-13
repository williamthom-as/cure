# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class RowGenerator < BaseGenerator
      private

      # @param [Cure::Transformation::RowCtx] source_value
      # @param [RowCtx] row_ctx
      def _generate(source_value, row_ctx)
        template = '<p class="foo"><%=content%></p>'
        html = Erb.new(template).result(row_ctx.rows)

        source_value
      end

      def columns
        @opts.fetch("columns", [])
      end

      def _describe; end
    end
  end
end
