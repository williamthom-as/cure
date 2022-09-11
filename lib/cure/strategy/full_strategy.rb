# frozen_string_literal: true

require "cure/strategy/base_strategy"

module Cure
  module Strategy
    class FullStrategy < BaseStrategy
      private

      # @param [String] source_value
      # @return [String]
      def _retrieve_value(source_value)
        source_value
      end

      # @param [String] _source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(_source_value, generated_value)
        generated_value
      end
    end
  end
end
