# frozen_string_literal: true

require "cure/generator/base_generator"
require "erb"

module Cure
  module Generator
    class ProcGenerator < BaseGenerator
      private

      # @param [Cure::Transformation::RowCtx] source_value
      # @param [RowCtx] row_ctx
      def _generate(source_value, row_ctx)
        proc = @options.fetch(:execute, nil)
        proc.call(source_value, row_ctx)
      end

      def _describe; end
    end
  end
end
