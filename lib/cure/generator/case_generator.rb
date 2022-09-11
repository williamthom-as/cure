# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class CaseGenerator < BaseGenerator
      private

      # @param [Object] source_value
      def _generate(source_value)
        result = case_options.fetch("switch").find { |opts| opts["case"] == source_value }&.fetch("return_value", nil)

        return result if result

        case_options.fetch("else", {}).fetch("return_value", nil)
      end

      # @return [Hash]
      def case_options
        @case_options ||= extract_property("statement", nil)
      end
    end
  end
end
