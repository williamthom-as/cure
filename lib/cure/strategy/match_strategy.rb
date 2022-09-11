# frozen_string_literal: true

require "cure/strategy/base_strategy"

module Cure
  module Strategy
    class MatchStrategy < BaseStrategy
      # Additional details needed to make substitution.
      # @return [MatchStrategyParams]
      attr_accessor :params

      def initialize(options)
        super(MatchStrategyParams.new(options))
      end

      # gsub catchment group
      # @param [String] source_value
      def _retrieve_value(source_value)
        @params.match || nil if source_value.include? @params.match
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        return unless source_value.include? @params.match

        source_value.gsub(@params.match, generated_value)
      end
    end

    class MatchStrategyParams < BaseStrategyParams
      attr_reader :match

      validates :match

      def initialize(options=nil)
        @match = options["match"]
        super(options)
      end
    end
  end
end
