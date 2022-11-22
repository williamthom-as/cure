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



      ## Old code

      # # @param [Array<Array>] csv_rows
      # # @return [Array<Hash>]
      # # rubocop:disable Metrics/AbcSize
      # def extract_named_ranges(csv_rows)
      #   # Use only the NR's that are defined from the candidates list
      #   candidates = config.template.transformations.candidates
      #   candidate_nrs = config.template.extraction.required_named_ranges(candidates.map(&:named_range).uniq)
      #
      #   candidate_nrs.map do |nr|
      #     rows = extract_from_rows(csv_rows, nr["section"])
      #     ctx = Extract::CSVContent.new
      #
      #     if nr["headers"]
      #       ctx.extract_column_headers(extract_from_rows(csv_rows, nr["headers"])&.first)
      #       ctx.add_rows(rows)
      #     else
      #       ctx.extract_column_headers(rows[0])
      #       ctx.add_rows(rows[1..])
      #     end
      #
      #     {
      #       "content" => ctx,
      #       "name" => nr["name"]
      #     }
      #   end
      # end
      # # rubocop:enable Metrics/AbcSize
      #
      # # @param [Array<Array>] csv_rows
      # # @return [Hash]
      # def extract_variables(csv_rows)
      #   config.template.extraction.variables.each_with_object({}) do |variable, hash|
      #     hash[variable["name"]] = lookup_location(csv_rows, variable["location"])
      #   end
      # end
      #
      # # @param [Array<Array>] rows
      # def extract_from_rows(rows, named_range)
      #   psx = CsvLookup.array_position_lookup(named_range)
      #
      #   ret_val = []
      #   rows.each_with_index do |row, idx|
      #     # If the position of the end row is -1, we need all,
      #     # otherwise if its between/equal to start/finish
      #     ret_val << row[psx[0]..psx[1]] if psx[3] == -1 || (idx >= psx[2] && idx <= psx[3])
      #   end
      #
      #   ret_val
      # end
      #
      # # @param [Array<Array>] rows
      # # @param [String] variable_location
      # def lookup_location(rows, variable_location)
      #   psx = [CsvLookup.position_for_letter(variable_location),
      #          CsvLookup.position_for_digit(variable_location)]
      #   rows[psx[1]][psx[0]]
      # end

    end
  end
end

