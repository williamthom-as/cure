# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/csv_lookup"

require "csv"

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
        candidate_column_names = []
        columns.each_with_index do |col, idx|
          candidate_column_names << (col || "col_#{idx}")
        end

        @database_service.create_table(tbl_name.to_sym, candidate_column_names)
      end

      def insert_record(tbl_name, values)
        @database_service.insert_row(tbl_name.to_sym, values)
      end

      def insert_batched_rows(tbl_name, values)
        @database_service.insert_batched_rows(tbl_name.to_sym, values)
      end
    end
  end
end
