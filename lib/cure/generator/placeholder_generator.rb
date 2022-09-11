# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class PlaceholderGenerator < BaseGenerator
      include Configuration

      private

      # @param [Object] _source_value
      def _generate(_source_value)
        value = config.placeholders[property_name]
        value || raise("Missing placeholder value. Available candidates: [#{config.placeholders.keys.join(", ")}]")
      end
    end
  end
end
