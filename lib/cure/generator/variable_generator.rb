# frozen_string_literal: true

require "cure/generator/base_generator"
require "cure/config"

module Cure
  module Generator
    class VariableGenerator < BaseGenerator
      include Database

      private

      # @param [object] _source_value
      # @param [RowCtx] _row_ctx
      def _generate(_source_value, _row_ctx)
        value = database_service.find_variable(property_name)
        value || raise("Missing placeholder value")
      end

      def _describe
        "Will look up the variables defined using '#{property_name}'."
      end
    end
  end
end
