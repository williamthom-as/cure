# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/csv_lookup"
require "cure/helpers/file_helpers"
require "cure/extract/wrapped_csv"

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

      # @param [File, Not Nil] csv_file
      # @return [WrappedCSV]
      def extract_from_file(csv_file)
        extract_from_contents(csv_file.read)
      end

      # @param [String] file_contents
      # @return [WrappedCSV]
      def extract_from_contents(file_contents)
        parsed_content = parse_csv(file_contents, header: :none)
        log_info("Parsed CSV into #{parsed_content.content.length} sections.")
        parsed_content
      end

      # private

      # @param [String] file_contents
      # @param [Hash] opts
      # @return [WrappedCSV]
      def parse_csv(file_contents, opts={})
        csv_rows = []

        Rcsv.parse(file_contents, opts) { |row| csv_rows << row }

        result = WrappedCSV.new
        result.content = extract_named_ranges(csv_rows)
        result.variables = extract_variables(csv_rows)

        result
      end

      # @param [Array<Array>] csv_rows
      # @return [Array<Hash>]
      # rubocop:disable Metrics/AbcSize
      def extract_named_ranges(csv_rows)
        # Use only the NR's that are defined from the candidates list
        candidates = config.template.transformations.candidates
        candidate_nrs = config.template.extraction.required_named_ranges(candidates.map(&:named_range).uniq)

        candidate_nrs.map do |nr|
          rows = extract_from_rows(csv_rows, nr["section"])
          ctx = Extract::CSVContent.new

          # TODO: We should allow someone to choose the row header.. this could be troublesome if the headers come
          # from a different NR/part of doc. Need to think about it.
          # Current working thought, add it to the extraction

          if nr["headers"]
            ctx.extract_column_headers(extract_from_rows(csv_rows, nr["headers"])&.first)
            ctx.add_rows(rows)
          else
            ctx.extract_column_headers(rows[0])
            ctx.add_rows(rows[1..])
          end

          {
            "content" => ctx,
            "name" => nr["name"]
          }
        end
      end
      # rubocop:enable Metrics/AbcSize

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

      # Commented out for now, not needed.rsp
      # @param [Integer] row_idx
      # @param [Array] row
      # @param [Array] psx
      # @return [Array, nil]
      # def handle_row(row_idx, row, psx)
      #   return nil unless psx[3] == -1 || (row_idx >= psx[2] && row_idx <= psx[3])
      #
      #   row[psx[0]..psx[1]]
      # end
    end
  end
end
