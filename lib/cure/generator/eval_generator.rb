# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class GuidGenerator < BaseGenerator
      private

      # @param [Object] _source_value
      # @param [RowCtx] _row_ctx
      # This will be changed with expression evaluator
      def _generate(_source_value, _row_ctx)
        eval_str = extract_property("eval", nil)
        with_safe do
          eval(eval_str)
        end
      rescue StandardError => e
        raise "Cannot eval statement #{extract_property("eval", nil)} [#{e.message}]"
      end

      def with_safe(&_block)
        $SAFE = 1
        yield
        $SAFE = 0
      end

    end


  end
end
