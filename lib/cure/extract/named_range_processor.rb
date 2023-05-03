# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/csv_lookup"

require "csv"
require "objspace"

module Cure
  module Extract
    class BaseProcessor

      # @return [Cure::DatabaseService]
      attr_reader :database_service

      def initialize(database_service)
        @database_service = database_service
      end

      protected

      def create_table(tbl_name, columns)
        @database_service.create_table(tbl_name.to_sym, columns)
      end

      def insert_record(tbl_name, row_idx, values)
        values.unshift(row_idx) # Add id to front of array
        @database_service.insert_row(tbl_name.to_sym, values)
      end

    end

    class NamedRangeProcessor < BaseProcessor

      # @return [Array<Extraction::NamedRange>] named_ranges
      attr_reader :candidate_nrs

      def initialize(database_service, candidate_nrs)
        @candidate_nrs = candidate_nrs
        @cache = init_cache

        super database_service
      end

      # @param [Integer] row_idx
      # @param [Array] csv_row
      def process_row(row_idx, csv_row) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
        # Return if row is not in any named range
        return unless row_bounds.cover?(row_idx)

        # Iterate over the NR's, if its inside those bounds, add it
        @candidate_nrs.each do |nr|
          next unless nr.row_in_bounds?(row_idx)

          # Row is inbounds - we need to do two things, filter the content, create the table, insert the row
          if nr.header_in_bounds?(row_idx)
            column_headers = csv_row[nr.section[0]..nr.section[1]]

            # Create table, flush cache
            create_table(nr.name, column_headers)
            @cache[nr.name].each do |val|
              # This row idx will fail, cannot use same id
              insert_record(nr.name, row_idx, val)
            end

            @cache[nr.name] = []

            next
          end

          next unless nr.content_in_bounds?(row_idx)

          # If the table exists, add it to the database
          if @database_service.table_exist? nr.name.to_sym
            insert_record(nr.name, row_idx, csv_row[nr.section[0]..nr.section[1]])
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
    end

    class VariableProcessor < BaseProcessor

      # @return [Array<Extraction::Variable>] variables
      attr_reader :candidate_variables

      def initialize(database_service, candidate_variables)
        super database_service

        @candidate_variables = candidate_variables
        @candidate_count = candidate_variables.length
        @processed = 0

        init_db
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

          insert_record(:variables, (@processed + 1), [cv.name, csv_row[cv.location.first]])
          @processed += 1
        end
      end

      # @return [Array]
      def candidate_rows
        @candidate_rows ||= @candidate_variables.map { |v| v.location.last }
      end

      private

      def init_db
        create_table(:variables, %w[name value])
      end
    end
  end
end
