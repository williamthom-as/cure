# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/csv_lookup"
require "cure/extract/base_processor"

require "csv"

module Cure
  module Extract
    class NamedRangeProcessor < BaseProcessor

      # @return [Array<Extraction::NamedRange>] named_ranges
      attr_reader :candidate_nrs

      def initialize(database_service, candidate_nrs)
        @candidate_nrs = candidate_nrs
        @cache = init_cache

        @tables_created = []
        super database_service
      end

      # @param [Integer] row_idx
      # @param [Array] csv_row
      def process_row(row_idx, csv_row) # rubocop:disable all
        # Return if row is not in any named range
        return unless row_bounds.cover?(row_idx)

        # Iterate over the NR's, if its inside those bounds, add it
        @candidate_nrs.each do |nr|
          next unless nr.row_in_bounds?(row_idx)

          if nr.filter.row_handler.has_content?
            unless nr.filter.row_handler.including_proc[:where].call(csv_row)
              nr.row_count += 1
              next
            end
          end

          # Row is inbounds - we need to do two things, filter the content, create the table, insert the row
          if nr.header_in_bounds?(nr.active_row_count(row_idx))
            column_headers = csv_row[nr.section[0]..nr.section[1]]

            if nr.filter.col_handler.has_content?
              nr.filter.col_handler.set_col_positions(column_headers)
              column_headers = nr.filter.col_handler.translate_headers(column_headers)
            end

            # Create table, flush cache
            create_table(nr.name, column_headers)
            @tables_created << nr.name

            @cache[nr.name].each do |row|
              insert_record(
                nr.name,
                nr.filter.col_handler.filter_row(row)
              )
            end

            @cache[nr.name] = [] # Evict cache

            next
          end

          next unless nr.content_in_bounds?(row_idx)

          # 0. Remove unnecessary columns


          # 2. If cache is over n records and if the table exists,
          # add it to the database.

          filtered_row = nr.filter.col_handler.filter_row(
            csv_row[nr.section[0]..nr.section[1]]
          )

          if @tables_created.include?(nr.name)
            @cache[nr.name] << filtered_row.unshift(row_idx)

            if @cache[nr.name].size >= 10
              insert_cache(nr.name)
              next
            end
          else
            # If the table doesnt exist, cache it for now.
            @cache[nr.name] << filtered_row.unshift(row_idx)
          end
        end
      end

      def after_process
        @cache.each do |named_range, cache|
          insert_cache(named_range) if cache.size.positive?
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

      def insert_cache(named_range)
        insert_batched_rows(named_range, @cache[named_range])
        @cache[named_range] = []
      end
    end
  end
end
