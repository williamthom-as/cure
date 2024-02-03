# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/base_processor"

require "csv"

module Cure
  module Extract
    class VariableProcessor < BaseProcessor

      # @return [Array<Extraction::Variable>] variables
      attr_reader :candidate_variables

      def initialize(database_service, candidate_variables)
        super(database_service)

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

          insert_record(:variables, [nil, cv.name, csv_row[cv.location.first]])
          @processed += 1
        end
      end

      # @return [Array]
      def candidate_rows
        @candidate_rows ||= @candidate_variables.map { |v| v.location.last }
      end

      private

      def init_db
        return if @database_service.table_exist?(:variables)

        create_table(:variables, %w[name value])
      end
    end
  end
end
