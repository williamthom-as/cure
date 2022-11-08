# frozen_string_literal: true

require "cure/strategy/base_strategy"

module Cure
  module Strategy
    class EndWithStrategy < BaseStrategy
      # Additional details needed to make substitution.
      # @return [EndWithStrategyParams]
      attr_accessor :params

      def initialize(options)
        super(EndWithStrategyParams.new(options))
      end

      # gsub catchment group
      # @param [String] source_value
      def _retrieve_value(source_value)
        @params.match || nil if source_value.end_with? @params.match
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        return unless source_value.end_with? @params.match

        return generated_value unless replace_partial_record

        generated_value + @params.match
        # generated_value + source_value.reverse.chomp(@options["match"].reverse).reverse
      end

      def _describe
        "End with replacement will look for '#{@params.match}'. " \
        "It will do a #{replace_partial_record ? "partial" : "full"} replacement. " \
        "[Note: If the value does not include '#{@params.match}', no substitution is made.]"
      end
    end

    class EndWithStrategyParams < BaseStrategyParams
      attr_reader :match

      validates :match

      def initialize(options=nil)
        @match = options["match"]
        super(options)
      end
    end
  end
end
