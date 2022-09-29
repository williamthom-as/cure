# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/csv_lookup"
require "cure/helpers/file_helpers"

module Cure
  module Extract
    class Extractor
      include Log
      include Configuration
      include Helpers::FileHelpers

      # @param [Hash] opts
      attr_reader :opts

      # @param [Hash] opts
      def initialize(opts)
        @opts = opts
      end

      # @param [String] csv_file_location
      # @return [ParsedCSV]
      def extract_from_file(csv_file_location)
        file_contents = read_file(csv_file_location)
        extract_from_contents(file_contents)
      end

      # @param [String] file_contents
      # @return [ParsedCSV]
      def extract_from_contents(file_contents)
        parsed_content = parse_csv(file_contents, header: :none)
        log_info("Parsed CSV into #{parsed_content.content.length} sections.")
        parsed_content
      end

      # private

      # @param [String] file_contents
      # @param [Hash] opts
      # @return [ParsedCSV]
      def parse_csv(file_contents, opts={})
        csv_rows = []

        Rcsv.parse(file_contents, opts) { |row| csv_rows << row }

        result = ParsedCSV.new
        result.content = extract_named_ranges(csv_rows)
        result.variables = extract_variables(csv_rows)

        result
      end

      # @param [Array<Array>] csv_rows
      # @return [Array<Hash>]
      def extract_named_ranges(csv_rows)
        # Use only the NR's that are defined from the candidates list
        candidates = config.template.transformations.candidates
        candidate_nrs = config.template.extraction.required_named_ranges(candidates.map(&:named_range).uniq)
        candidate_nrs.map do |nr|
          {
            "rows" => extract_from_rows(csv_rows, nr["section"]),
            "name" => nr["name"]
          }
        end
      end

      # @param [Array<Array>] csv_rows
      # @return [Hash]
      def extract_variables(csv_rows)
        config.template.extraction.variables.each_with_object({}) do |variable, hash|
          hash[variable["name"]] = lookup_location(csv_rows, variable["location"])
        end
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

      # @param [Array<Array>] rows
      # @param [String] variable_location
      def lookup_location(rows, variable_location)
        psx = [CsvLookup.position_for_letter(variable_location),
               CsvLookup.position_for_digit(variable_location)]
        rows[psx[1]][psx[0]]
      end

      # @param [Integer] row_idx
      # @param [Array] row
      # @param [Array] psx
      # @return [Array, nil]
      def handle_row(row_idx, row, psx)
        return nil unless psx[3] == -1 || (row_idx >= psx[2] && row_idx <= psx[3])

        row[psx[0]..psx[1]]
      end
    end

    class ParsedCSV
      # @return [Array<Hash>]
      attr_accessor :content

      # @return [Hash]
      attr_accessor :variables

      def initialize
        @content = []
        @variables = {}
      end
    end
  end
end
