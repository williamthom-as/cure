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
        existing = retrieve_history(source_value)
        return existing if existing

        value = _retrieve_value(generator, source_value)
        store_history(source_value, value)

        value
      end

      private

      # @param [Generator::Base] _generator
      # @param [String] _source_value
      def _retrieve_value(_generator, _source_value)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      # @return [Boolean]
      def use_existing
        !!@options[:use_existing]
      end

    end

    class FullStrategy < Base

      private

      # @param [Generator::Base] generator
      # @param [String] _source_value
      def _retrieve_value(generator, _source_value)
        generator.generate
      end

    end

    class RegexStrategy < Base
      # gsub catchment group
      # @param [Generator::Base] generator
      # @param [String] source_value
      def _retrieve_value(generator, source_value)
        m = /#{@options["regex_cg"]}/.match(source_value)
        return unless m.instance_of?(MatchData)

        source_value.gsub(m[1], generator.generate.to_s)
      end
    end

  end
end
