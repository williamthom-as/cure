# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/csv_lookup"

require "csv"
require "objspace"

module Cure
  module Extract
    class NamedRangeProcessor

      # @return [Array<Extraction::NamedRange>] named_ranges
      attr_reader :candidate_nrs

      # @return [Hash<String,Extract::CSVContent>] named_ranges
      attr_reader :results

      def initialize(candidate_nrs)
        @candidate_nrs = candidate_nrs
        @results = {}
      end

      # @param [Integer] row_idx
      # @param [Array] csv_row
      def process_row(row_idx, csv_row) # rubocop:disable Metrics/AbcSize
        # Return if row is not in any named range
        return unless row_bounds.cover?(row_idx)

        # Iterate over the NR's, if its inside those bounds, add it
        @candidate_nrs.each do |nr|
          next unless nr.row_in_bounds?(row_idx)

          @results[nr.name] = Extract::CSVContent.new unless @results.key?(nr.name)

          if nr.header_in_bounds?(row_idx)
            @results[nr.name].extract_column_headers(csv_row[nr.section[0]..nr.section[1]])
            next
          end

          @results[nr.name].add_row(csv_row[nr.section[0]..nr.section[1]])
        end
      end

      # @return [Range]
      def row_bounds
        @row_bounds ||= calculate_row_bounds
      end

      # @return [Range]
      def calculate_row_bounds
        positions = @candidate_nrs.map(&:row_bounds).flatten.sort
        (positions.first..positions.last)
      end
    end

    class VariableProcessor
      # @return [Array<Extraction::Variable>] variables
      attr_reader :candidate_variables

      # @return [Hash<String,Object>] csv_variables
      attr_reader :results

      def initialize(candidate_variables)
        @candidate_variables = candidate_variables
        @results = {}

        @candidate_count = candidate_variables.length
        @processed = 0
      end

      # @param [Integer] row_idx
      # @param [Array] csv_row
      def process_row(row_idx, csv_row)
        # Return if row is not in any variable OR if all candidates are processed.

        return if @candidate_count == @processed
        return unless candidate_rows.include?(row_idx)

        # Iterate over the NR's, if its inside those bounds, add it
        @candidate_variables.each do |cv|
          next unless cv.row_in_bounds?(row_idx)

          @results[cv.name] = csv_row[cv.location.first]
          @processed += 1
        end
      end

      # @return [Array]
      def candidate_rows
        @candidate_rows ||= @candidate_variables.map { |v| v.location.last }
      end
    end
  end
end

