# frozen_string_literal: true

require "cure/generator/base_generator"
require "erb"

module Cure
  module Generator
    class ErbGenerator < BaseGenerator
      private

      # @param [Cure::Transformation::RowCtx] _source_value
      # @param [RowCtx] row_ctx
      def _generate(_source_value, row_ctx)
        template = @options.fetch(:template, nil)
        ERB.new(template).result_with_hash(row_ctx.row)
      end

      def _describe; end
    end
  end
end
