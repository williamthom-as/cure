# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/csv_lookup"

require "csv"
require "objspace"

module Cure
  module Extract
    class NamedRangeProcessor

      # @return [Cure::DatabaseService]
      attr_reader :database_service

      # @return [Array<Extraction::NamedRange>] named_ranges
      attr_reader :candidate_nrs

      # @return [Hash<String,Extract::CSVContent>] named_ranges
      attr_reader :results

      def initialize(database_service, candidate_nrs)
        @database_service = database_service
        @candidate_nrs = candidate_nrs
        @results = {}

        @cache = init_cache
      end

      # @param [Integer] row_idx
      # @param [Array] csv_row
      def process_row(row_idx, csv_row) # rubocop:disable Metrics/AbcSize
        # Return if row is not in any named range
        return unless row_bounds.cover?(row_idx)

        # Iterate over the NR's, if its inside those bounds, add it
        @candidate_nrs.each do |nr|
          next unless nr.row_in_bounds?(row_idx)

          # Row is inbounds - we need to do two things, create the table, insert the row
          @results[nr.name] = Extract::CSVContent.new unless @results.key?(nr.name)

          if nr.header_in_bounds?(row_idx)
            column_headers = csv_row[nr.section[0]..nr.section[1]]
            @results[nr.name].extract_column_headers(column_headers)

            # Create table, flush cache
            create_nr_table(nr.name, column_headers)
            @cache[nr.name].each do |val|
              insert_row(nr.name, row_idx, val)
            end

            @cache[nr.name] = []

            next
          end

          # If the table exists, add it to the database
          if @database_service.table_exist? nr.name.to_sym
            values = csv_row[nr.section[0]..nr.section[1]]

            @results[nr.name].add_row(values) # legacy

            insert_row(nr.name, row_idx, values)
            next
          end

          # If the table doesnt exist, cache it for now.
          @cache[nr.name] << csv_row[nr.section[0]..nr.section[1]]
        end
      end

      # @return [Range]
      # This covers the max size of all named ranges
      def row_bounds
        @row_bounds ||= calculate_row_bounds
      end

      # @return [Range]
      def calculate_row_bounds
        positions = @candidate_nrs.map(&:row_bounds).flatten.sort
        (positions.first..positions.last)
      end

      private

      def init_cache
        cache = {}
        @candidate_nrs.each do |nr|
          cache[nr.name] = []
        end

        cache
      end

      def create_nr_table(nr_name, columns)
        @database_service.create_table(nr_name.to_sym, columns)
      end

      def insert_row(nr_name, row_idx, values)
        values.unshift(row_idx)

        @database_service.insert_row(nr_name.to_sym, values)
      end
    end

    class VariableProcessor
      # @return [Cure::DatabaseService]
      attr_reader :database_service

      # @return [Array<Extraction::Variable>] variables
      attr_reader :candidate_variables

      # @return [Hash<String,Object>] csv_variables
      attr_reader :results

      def initialize(database_service, candidate_variables)
        @database_service = database_service
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

