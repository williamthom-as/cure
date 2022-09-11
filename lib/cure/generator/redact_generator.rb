# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class RedactGenerator < BaseGenerator
      private

      # @param [Object] source_value
      def _generate(source_value)
        1.upto(length(source_value&.length || 5)).map { "X" }.join("")
      end
    end
  end
end
