# frozen_string_literal: true

require "singleton"
require "cure/validators"
require "cure/strategy/history/history_cache"

module Cure
  module Strategy
    class BaseStrategy
      include History

      # Additional details needed to make substitution.
      # @return [BaseStrategyParams]
      attr_accessor :params

      def initialize(params)
        # Is there a better way to do this? If its a base, we take a {}, if super
        # defines it, we just use that instance.
        @params = params.is_a?(Hash) ? BaseStrategyParams.new(params) : params
      end

      # @param [String] source_value
      # @param [Transformation::RowCtx,nil] row_ctx
      # @param [Generator::BaseGenerator] generator
      # @return [String]
      #
      # This will retrieve the (partial) value, then generate a new replacement.
      def extract(source_value, row_ctx, generator)
        extracted_value = _retrieve_value(source_value)
        existing = retrieve_history(extracted_value)

        return _replace_value(source_value, existing) if existing && !@params.force_replace

        generated_value = generator.generate(source_value, row_ctx)&.to_s
        value = _replace_value(source_value, generated_value)

        store_history(extracted_value, generated_value)

        value
      end

      def describe
        _describe
      end

      private

      def replace_partial_record
        replace_partial = @params.replace_partial
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

      def _describe
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class BaseStrategyParams
      include Validators::Helpers
      extend Validators

      # Additional details needed to make substitution.
      # @return [Hash]
      attr_accessor :options
      attr_accessor :replace_partial, :force_replace

      def initialize(options={})
        @replace_partial = options[:replace_partial] || false
        @force_replace = options[:force_replace] || false
        @options = options

        validate_params
      end

      def validate_params
        valid?
      end
    end
  end
end
