# frozen_string_literal: true

require "cure/strategy/base_strategy"

module Cure
  module Strategy
    class ContainStrategy < BaseStrategy
      # Additional details needed to make substitution.
      # @return [ContainStrategyParams]
      attr_accessor :params

      def initialize(options)
        super(ContainStrategyParams.new(options))
      end

      # @param [String] source_value
      def _retrieve_value(source_value)
        return unless source_value.include?(@params.match)

        @params.match
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        return unless source_value.include?(@params.match)

        source_value.gsub(@params.match, generated_value)
      end

      def _describe
        "Replacing matched value on '#{@params.value}') " \
        "[Note: If the value does not include '#{@params.value}', no substitution is made.]"
      end
    end

    class ContainStrategyParams < BaseStrategyParams
      attr_reader :match

      validates :match, validator: :presence

      def initialize(options=nil)
        @match = options[:match]
        # valid?

        super(options)
      end
    end
  end
end
