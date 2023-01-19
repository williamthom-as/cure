# frozen_string_literal: true

require "cure/strategy/base_strategy"

module Cure
  module Strategy
    class SplitStrategy < BaseStrategy
      # Additional details needed to make substitution.
      # @return [SplitStrategyParams]
      attr_accessor :params

      def initialize(options)
        super(SplitStrategyParams.new(options))
      end

      # @param [String] source_value
      def _retrieve_value(source_value)
        return unless source_value.include?(@params.token)

        result_arr = source_value.split(@params.token)
        result_arr[@params.index]
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        split_token = @params.token

        return unless source_value.include?(split_token)

        result_arr = source_value.split(split_token)
        result_arr[@params.index] = generated_value if value?(result_arr[@params.index])
        result_arr.join(split_token)
      end

      def _describe
        "Splitting on '#{@params.token}', at index #{@params.index}) " \
        "[Note: If the value does not include '#{@params.token}', no substitution is made.]"
      end
    end

    class SplitStrategyParams < BaseStrategyParams
      attr_reader :token, :index

      validates :token, validator: :presence
      validates :index, validator: :presence

      def initialize(options=nil)
        @token = options[:token]
        @index = options[:index]
        # valid?

        super(options)
      end
    end
  end
end
