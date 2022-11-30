# frozen_string_literal: true

require "cure/log"

module Cure
  module Extract
    class RowContext

      # @return [Map<String, Integer>]
      attr_accessor :headers

      # @return [Array]
      attr_accessor :row

      def initialize(headers, row)
        @headers = headers
        @row = row
      end

      # @param [String] key
      # @return [Object]
      def value_for_column(key)
        @row[@headers[key]]
      end
    end
  end
end
