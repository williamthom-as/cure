# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class EvalGenerator < BaseGenerator
      private

      # @param [Object] _source_value
      # @param [Transformation::RowCtx] row_ctx
      # This will be changed with expression evaluator
      def _generate(_source_value, row_ctx)
        eval_str = extract_property("eval", nil)
        result = nil
        with_safe do
          result = eval(eval_str)
        end

        result
      rescue StandardError => e
        raise "Cannot eval statement #{extract_property("eval", nil)} [#{e.message}]"
      end

      def with_safe(&_block)
        $SAFE = 1
        yield
        $SAFE = 0
      end

      # @param [String] col_name
      # @param [Transformation::RowCtx] row_ctx
      def from_column(col_name, row_ctx)
        col_idx = row_ctx.column_headers.fetch(col_name, nil)
        raise "Missing column for #{col_name}" unless col_idx

        row_ctx.rows[col_idx]
      end
    end
  end
end
