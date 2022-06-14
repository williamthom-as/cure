# frozen_string_literal: true

require "singleton"

module Cure
  module Strategy
    # Singleton Strategy for storing data across all processes
    module History

      # @return [Hash]
      def history
        HistoryCache.instance.history_cache
      end

      # @return [String]
      def retrieve_history(source_value)
        history[source_value]
      end

      # @param [String] source_value
      # @param [String] value
      def store_history(source_value, value)
        history[source_value] = value
      end

      class HistoryCache
        include Singleton

        attr_reader :history_cache

        def initialize
          @history_cache = {}
        end
      end
    end

    class Base
      include History

      # Additional details needed to make substitution.
      # @return [Hash]
      attr_accessor :options

      def initialize(options)
        @options = options
        @history = {}
      end

      # @param [String] source_value
      # @param [Generator::Base] generator
      # @return [String]
      def extract(source_value, generator)
        extracted_value = _retrieve_value(source_value)

        existing = retrieve_history(extracted_value)
        return _replace_value(source_value, existing) if existing

        generated_value = generator.generate.to_s
        value = _replace_value(source_value, generated_value)

        store_history(extracted_value, generated_value)

        value
      end

      private

      # @param [String] _source_value
      def _retrieve_value(_source_value)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      # @param [String] _source_value
      # @param [String] _generated_value
      # @return [String]
      def _replace_value(_source_value, _generated_value)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

    end

    class FullStrategy < Base

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

    class RegexStrategy < Base

      # gsub catchment group
      # @param [String] source_value
      def _retrieve_value(source_value)
        m = /#{@options["regex_cg"]}/.match(source_value)
        return unless m.instance_of?(MatchData)

        m[1]
        # source_value.gsub(m[1], generator.generate.to_s)
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        m = /#{@options["regex_cg"]}/.match(source_value)
        return unless m.instance_of?(MatchData)

        source_value.gsub(m[1], generated_value)
      end
    end

  end
end
