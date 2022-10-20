# frozen_string_literal: true

require "cure/generator/base_generator"
require "cure/config"

module Cure
  module Generator
    class PlaceholderGenerator < BaseGenerator
      include Cure::Configuration

      private

      # @param [Object] _source_value
      # @param [RowCtx] _row_ctx
      def _generate(_source_value, _row_ctx)
        value = config.placeholders[property_name]
        value || raise("Missing placeholder value. Available candidates: [#{config.placeholders.keys.join(", ")}]")
      end
    end
  end
end
