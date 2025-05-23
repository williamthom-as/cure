# frozen_string_literal: true

module Cure
  module Extract
    class CsvLookup

      X_MAX_LIMIT = 1_023
      Y_MAX_LIMIT = 10_000_000
      INVALID_FORMAT_REGEX = /^(?![A-Z]{1,3}(\d+)?:[A-Z]{1,3}(\d+)?$).*/

      # @param [String,Integer] position - [Ex A1:B1, A1:B1, A2:B2, A:B2, A:B]
      # @return [Array] [column_start_idx, column_end_idx, row_start_idx, row_end_idx]
      def self.array_position_lookup(position)
        return [0, X_MAX_LIMIT, 0, Y_MAX_LIMIT] if position.is_a?(Integer) && position == -1 # Whole sheet

        if position.upcase.match?(INVALID_FORMAT_REGEX)
          raise ArgumentError,
            "Invalid position format: '#{position}'. Expected format like 'A1:B10', 'A:B', 'AMJ1:C100'," \
              "where column is 1-3 letters and row part is optional digits."
        end

        start, finish, *_excess = position.split(":")

        [
          position_for_letter(start),
          position_for_letter(finish),
          position_for_digit(start, if_digit_nil: 0),
          position_for_digit(finish, if_digit_nil: Y_MAX_LIMIT)
        ]
      end

      # @param [String] range
      def self.position_for_letter(range)
        result = 0
        range.upcase.scan(/[A-Z]+/).first&.each_char do |n|
          result *= 26
          result += n.ord - 65 + 1
        end

        # Excel columns are not 0th indexed.
        result - 1
      end

      # @param [String] range
      def self.position_for_digit(range, if_digit_nil: nil)
        digit = range.upcase.scan(/\d+/).first
        return digit.to_i - 1 if digit && digit != ""

        if_digit_nil
      end
    end
  end
end
