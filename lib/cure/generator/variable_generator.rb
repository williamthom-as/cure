# frozen_string_literal: true

require "cure/generator/base_generator"
require "cure/config"

module Cure
  module Generator
    class VariableGenerator < BaseGenerator
      include Cure::Configuration

      private

      # @param [object] _source_value
      # @param [RowCtx] _row_ctx
      def _generate(_source_value, _row_ctx)
        value = config.variables[property_name]
        value || raise("Missing placeholder value. Available candidates: [#{config.variables.keys.join(", ")}]")
      end
    end
  end
end
