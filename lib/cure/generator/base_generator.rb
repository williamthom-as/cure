# frozen_string_literal: true

module Cure
  module Generator
    class BaseGenerator
      # @return [Hash]
      attr_accessor :options

      def initialize(options={})
        @options = options
      end

      # @param [Object/Nil] source_value
      # @param [RowCtx/Nil] row_ctx
      # @return [String]
      def generate(source_value, row_ctx)
        translated = _generate(source_value, row_ctx)
        translated = "#{prefix}#{translated}" if prefix
        translated = "#{translated}#{suffix}" if suffix
        translated
      end

      private

      # @param [RowCtx] _row_ctx
      # @param [Object/Nil] _source_value
      # @return [String]
      def _generate(_source_value, _row_ctx)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def prefix(default=nil)
        extract_property("prefix", default)
      end

      def suffix(default=nil)
        extract_property("suffix", default)
      end

      def length(default=nil)
        extract_property("length", default)
      end

      def property_name(default=nil)
        extract_property("name", default)
      end

      def extract_property(property, default_val)
        @options.fetch(property, default_val)
      end
    end
  end
end
