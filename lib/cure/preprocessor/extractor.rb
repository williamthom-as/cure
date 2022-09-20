# frozen_string_literal: true

require "cure/preprocessor/csv_lookup"

module Cure
  module Preprocessor
    class Extractor
      # @param [Hash] opts
      attr_reader :opts

      # @param [Hash] opts
      def initialize(opts)
        @opts = opts
      end

      # @param [Integer] row_idx
      # @param [Array] row
      # @param [Array] psx
      # @return [Array, nil]
      def handle_row(row_idx, row, psx)
        return nil unless psx[3] == -1 || (row_idx >= psx[2] && row_idx <= psx[3])

        row[psx[0]..psx[1]]
      end

      # @param [Array<Array>] rows
      def extract_from_rows(rows, named_range)
        psx = CsvLookup.array_position_lookup(named_range)

        ret_val = []
        rows.each_with_index do |row, idx|
          # If the position of the end row is -1, we need all,
          # otherwise if its between/equal to start/finish
          ret_val << row[psx[0]..psx[1]] if psx[3] == -1 || (idx >= psx[2] && idx <= psx[3])
        end

        ret_val
      end

      def lookup_location(rows, variable_location)
        psx = [CsvLookup.position_for_letter(variable_location),
               CsvLookup.position_for_digit(variable_location)]
        rows[psx[0]][psx[1]]
      end
    end
  end
end
