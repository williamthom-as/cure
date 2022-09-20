# frozen_string_literal: true

module Cure
  module Preprocessor
    class CsvLookup

      # @param [String] position - [Ex A1:B1, A1:B1,A2:B2]
      # @return [Array] [column_start_idx, column_end_idx, row_start_idx, row_end_idx]
      def self.array_position_lookup(position)
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

      def self.position_for_letter(range)
        range.upcase.scan(/[A-Z]+/).first.ord - 65 # A (65) - 65 = 0 idx
      end

      def self.position_for_digit(range)
        range.upcase.scan(/\d+/).first.to_i - 1
      end
    end
  end
end
