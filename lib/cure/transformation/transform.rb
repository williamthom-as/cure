# frozen_string_literal: true

module Cure
  module Transformation
    class Transform

      # @return [Array<Candidate>]
      attr_accessor :candidates

      # @return [Hash]
      attr_accessor :column_headers

      # @param [Array<Candidate>] candidates
      # @param [Hash] column_headers
      def initialize(candidates, column_headers)
        @candidates = candidates
        @column_headers = column_headers
      end

      # @param [Array] row
      # @return [Array]
      def transform(row)
        @candidates.each do |candidate|
          column_idx = @column_headers[candidate.column.to_sym]
          next unless column_idx

          existing_value = row[column_idx]
          next unless existing_value

          new_value = candidate.perform(existing_value) # transform value
          row[column_idx] = new_value
        end

        row
      end
    end
  end
end
