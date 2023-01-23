# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class StaticGenerator < BaseGenerator
      private

      # @param [Object] _source_value
      # @param [RowCtx] _row_ctx
      def _generate(_source_value, _row_ctx)
        @options.fetch(:value, nil)
      end

      def _describe
        "Will return the defined value [#{@options.fetch(:value, nil)}]"
      end
    end
  end
end
