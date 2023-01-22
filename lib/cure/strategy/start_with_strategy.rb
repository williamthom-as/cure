# frozen_string_literal: true

require "cure/strategy/base_strategy"

module Cure
  module Strategy
    class StartWithStrategy < BaseStrategy
      # validates :match

      # Additional details needed to make substitution.
      # @return [StartWithStrategyParams]
      attr_accessor :params

      def initialize(options)
        super(StartWithStrategyParams.new(options))
      end

      # gsub catchment group
      # @param [String] source_value
      def _retrieve_value(source_value)
        @params.match || nil if source_value.start_with? @params.match
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        return unless source_value.start_with? @params.match

        return generated_value unless replace_partial_record

        @params.match + generated_value
      end

      def _describe
        "Start with replacement will look for '#{@params.match}'. " \
        "It will do a #{replace_partial_record ? "partial" : "full"} replacement. " \
        "[Note: If the value does not include '#{@params.match}', no substitution is made.]"
      end
    end

    class StartWithStrategyParams < BaseStrategyParams
      attr_reader :match

      validates :match

      def initialize(options=nil)
        @match = options[:match]
        super(options)
      end
    end
  end
end
