# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class GuidGenerator < BaseGenerator
      private

      # @param [Object] _source_value
      # @param [RowCtx] _row_ctx
      def _generate(_source_value, _row_ctx)
        SecureRandom.uuid.to_s.slice(0, @options.fetch(:length, 36))
      end

      def _describe
        "Will create a random GUID."
      end
    end
  end
end
