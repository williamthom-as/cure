# frozen_string_literal: true

require "cure/strategy/base_strategy"

module Cure
  module Strategy
    class PrependStrategy < BaseStrategy
      private

      # @param [String] source_value
      # @return [String]
      def _retrieve_value(source_value)
        source_value
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        generated_value + source_value
      end

      def _describe
        "Prepend generated value to the end of source value"
      end
    end
  end
end
