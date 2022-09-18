# frozen_string_literal: true

module Cure
  module Cleanup
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
        psx = array_position_lookup(named_range)

        ret_val = []
        rows.each_with_index do |row, idx|
          # If the position of the end row is -1, we need all,
          # otherwise if its between/equal to start/finish
          ret_val << row[psx[0]..psx[1]] if psx[3] == -1 || (idx >= psx[2] && idx <= psx[3])
        end

        ret_val
      end

      # @param [String] position - [Ex A1:B1, A1:B1,A2:B2]
      # @return [Array] [column_start_idx, column_end_idx, row_start_idx, row_end_idx]
      def array_position_lookup(position)
        return [0, -1, 0, -1] if position.is_a?(Integer) && position == -1 # Whole sheet

        start, finish, *_excess = position.split(":")
        raise "Invalid format" unless start || finish

        [
          position_for_letter(start),
          position_for_letter(finish),
          position_for_digit(start),
          position_for_digit(finish)
        ]
      end

      private

      def position_for_letter(range)
        range.upcase.scan(/[A-Z]+/).first.ord - 65 # A (65) - 65 = 0 idx
      end

      def position_for_digit(range)
        range.upcase.scan(/\d+/).first.to_i - 1
      end
    end
  end
end
