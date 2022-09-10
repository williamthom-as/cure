# frozen_string_literal: true

require "singleton"
require "cure/validators"

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
        history[source_value] unless source_value.nil? || source_value == ""
      end

      # @param [String] source_value
      # @param [String] value
      def store_history(source_value, value)
        history[source_value] = value unless source_value.nil? || source_value == ""
      end

      def reset_history
        HistoryCache.instance.reset
      end
      alias clear_history reset_history

      class HistoryCache
        include Singleton

        attr_reader :history_cache

        def initialize
          @history_cache = {}
        end

        def reset
          @history_cache = {}
        end
      end
    end

    class Base
      extend Validators

      include Validators::Helpers
      include History

      # Additional details needed to make substitution.
      # @return [Hash]
      attr_accessor :options

      def initialize(options)
        @options = options
      end

      # @param [String] source_value
      # @param [Generator::Base] generator
      # @return [String]
      #
      # This will retrieve the (partial) value, then generate a new replacement.
      def extract(source_value, generator)
        extracted_value = _retrieve_value(source_value)

        existing = retrieve_history(extracted_value)
        return _replace_value(source_value, existing) if existing

        generated_value = generator.generate(source_value)&.to_s
        value = _replace_value(source_value, generated_value)

        store_history(extracted_value, generated_value)

        value
      end

      def obj_is_valid?
        valid?
      end

      private

      def replace_partial_record
        replace_partial = @options["replace_partial"]
        return replace_partial || false unless replace_partial.instance_of?(String)

        (replace_partial || "true").to_s == "true"
      end

      def value?(value)
        !value.nil? && value != ""
      end

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

      validates :regex_cg

      def initialize(options)
        @regex_cg = options["regex_cg"]
        super(options)
      end

      # gsub catchment group
      # @param [String] source_value
      def _retrieve_value(source_value)
        m = /#{@regex_cg}/.match(source_value)
        return unless m.instance_of?(MatchData) && (!m[1].nil? && m[1] != "")

        m[1]
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        m = /#{@regex_cg}/.match(source_value)
        return unless m.instance_of?(MatchData) && (!m[1].nil? && m[1] != "")

        generated_value unless replace_partial_record

        source_value.gsub(m[1], generated_value)
      end
    end

    class MatchStrategy < Base

      validates :match

      def initialize(options)
        @match = options["match"]
        super(options)
      end

      # gsub catchment group
      # @param [String] source_value
      def _retrieve_value(source_value)
        @match || nil if source_value.include? @match
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        return unless source_value.include? @match

        source_value.gsub(@match, generated_value)
      end
    end

    class StartWithStrategy < Base

      validates :match

      def initialize(options)
        @match = options["match"]
        super(options)
      end

      # gsub catchment group
      # @param [String] source_value
      def _retrieve_value(source_value)
        @match || nil if source_value.start_with? @match
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        return unless source_value.start_with? @match

        return generated_value unless replace_partial_record

        @match + generated_value
      end
    end

    class EndWithStrategy < Base

      validates :match

      def initialize(options)
        @match = options["match"]
        super(options)
      end

      # gsub catchment group
      # @param [String] source_value
      def _retrieve_value(source_value)
        @match || nil if source_value.end_with? @match
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        return unless source_value.end_with? @match

        return generated_value unless replace_partial_record

        generated_value + @match
        # generated_value + source_value.reverse.chomp(@options["match"].reverse).reverse
      end
    end

    class SplitStrategy < Base

      attr_reader :token, :index

      validates :token
      validates :index

      def initialize(options)
        @token = options["token"]
        @index = options["index"]

        super(options)
      end

      # @param [String] source_value
      def _retrieve_value(source_value)
        return unless source_value.include?(@token)

        result_arr = source_value.split(@token)
        result_arr[@index]
      end

      # @param [String] source_value
      # @param [String] generated_value
      # @return [String]
      def _replace_value(source_value, generated_value)
        split_token = @options["token"]

        return unless source_value.include?(split_token)

        result_arr = source_value.split(split_token)
        result_arr[@index] = generated_value if value?(result_arr[@index])
        result_arr.join(split_token)
      end
    end
  end
end
