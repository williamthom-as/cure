# frozen_string_literal: true

require "cure/strategy/base_strategy"

module Cure
  module Strategy
    class RegexStrategy < BaseStrategy
      # Additional details needed to make substitution.
      # @return [RegexStrategyParams]
      attr_accessor :params

      def initialize(options)
        super(RegexStrategyParams.new(options))
      end

      # gsub catchment group
      # @param [String] source_value
      def _retrieve_value(source_value)
        m = /#{@params.regex_cg}/.match(source_value)
        return unless m.instance_of?(MatchData) && (!m[1].nil? && m[1] != "")

        m[1]
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        m = /#{@params.regex_cg}/.match(source_value)
        return unless m.instance_of?(MatchData) && (!m[1].nil? && m[1] != "")

        generated_value unless replace_partial_record

        source_value.gsub(m[1], generated_value)
      end

      def _describe
        "Matching on '#{@params.regex_cg}'. " \
        "[Note: If the regex does not match, or has no capture group, no substitution is made.]"
      end

    end

    class RegexStrategyParams < BaseStrategyParams
      attr_reader :regex_cg

      validates :regex_cg

      def initialize(options=nil)
        @regex_cg = options[:regex_cg]
        super(options)
      end
    end
  end
end
