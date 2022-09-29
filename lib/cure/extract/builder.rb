# frozen_string_literal: true

require "cure/extract/csv_lookup"

module Cure
  module Extract
    class Builder

      # @param [Hash] opts
      attr_reader :opts

      # @param [Hash] opts
      def initialize(opts)
        @opts = opts
      end

      # @param [Array<Array>] _sheet
      # @param [Hash<String, Integer>] _column_headers
      # @return [Array]
      #
      # This returns changed column headers and sheets
      def handle(_sheet, _column_headers)
        []
      end
    end
  end
end
