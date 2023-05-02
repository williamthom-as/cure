# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/database"
require "cure/helpers/file_helpers"
require "cure/extract/extractor"

require "rcsv"

module Cure
  module Validator

    class BaseRule

      def initialize(named_range, column, options)
        @named_range = named_range
        @column = column
        @options = options
      end

      def process(_value)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def to_s
        "Base Rule"
      end
    end

    class NotNullRule < BaseRule
      def process(value)
        !value.nil?
      end

      def to_s
        "Not null"
      end
    end

    class LengthRule < BaseRule
      def process(value)
        return true if value.nil?
        return true unless value.respond_to? :size

        length = value.size
        length >= min && length <= max
      end

      def to_s
        "Length [Min: #{min}, Max: #{max}]"
      end

      def min
        @min || @options.fetch(:max, 0)
      end

      def max
        @max || @options.fetch(:max, (99_999))
      end
    end

    class CustomRule < BaseRule
      def process(value)
        return true if value.nil?

        custom_proc.call(value)
      end

      def to_s
        "Custom"
      end

      def custom_proc
        @options.fetch(:proc, Proc.new { |_x| false })
      end
    end
  end
end
