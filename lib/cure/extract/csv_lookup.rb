# frozen_string_literal: true

module Cure
  module Extract
    class CsvLookup

      # @param [String,Integer] position - [Ex A1:B1, A1:B1,A2:B2]
      # @return [Array] [column_start_idx, column_end_idx, row_start_idx, row_end_idx]
      def self.array_position_lookup(position)
        # This is a better way, still trying to figure out a better way but -1 doesn't work for ranges.
        # return [0, -1, 0, -1] if position.is_a?(Integer) && position == -1
        return [0, 1_023, 0, 10_000_000] if position.is_a?(Integer) && position == -1 # Whole sheet

        start, finish, *_excess = position.split(":")
        raise "Invalid format" unless start || finish

        [
          position_for_letter(start),
          position_for_letter(finish),
          position_for_digit(start),
          position_for_digit(finish)
        ]
      end

      def self.position_for_letter(range)
        result = 0
        range.upcase.scan(/[A-Z]+/).first&.each_char do |n|
          result *= 26
          result += n.ord - 65 + 1
        end

        # Excel columns are not 0th indexed.
        result - 1
      end

      def self.position_for_digit(range)
        range.upcase.scan(/\d+/).first.to_i - 1
      end
    end
  end
end
