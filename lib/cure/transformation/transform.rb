# frozen_string_literal: true

module Cure
  module Transformation
    class Transform

      # @return [Array<Candidate>]
      attr_accessor :candidates

      # @param [Array<Candidate>] candidates
      def initialize(candidates)
        @candidates = candidates
      end

      def run(csv_file_location, &block)
        Rcsv.parse(read_file(csv_file_location), {}, &block)
      end

      # @param [Hash] column_headers
      # @param [Array] row
      # @return [Array]
      def transform(column_headers, row)
        @candidates.each do |candidate|
          column_idx = column_headers[candidate.column.to_sym]
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
