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

      def initialize(named_range, column, opts)
        @named_range = named_range
        @column = column
        @opts = opts
      end

      def process
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def to_s
        "Base Rule"
      end
    end

    class NotNullRule < BaseRule
      def process
        true
      end

      def to_s
        "Not null"
      end
    end

    class LengthRule < BaseRule
      def process
        true
      end

      def to_s
        "Length"
      end
    end

    class CustomRule < BaseRule
      def process
        true
      end

      def to_s
        "Custom"
      end
    end
  end
end
