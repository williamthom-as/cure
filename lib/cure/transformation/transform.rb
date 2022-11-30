# frozen_string_literal: true

require "cure/log"
require "cure/helpers/file_helpers"
require "cure/config"
require "cure/extract/extractor"

require "rcsv"

module Cure
  module Transformation
    # Operational file for conducting transforms
    class Transform
      include Log
      include Helpers::FileHelpers
      include Configuration

      # @return [Array<Candidate>]
      attr_accessor :candidates

      # @param [Array<Candidate>] candidates
      def initialize(candidates)
        @candidates = candidates
      end

      # @param [Cure::Extract::WrappedCSV] wrapped_csv
      # @return [Hash<String,TransformResult>] # make this transformation results?
      def transform_content(wrapped_csv)
        trans_hash = {}
        wrapped_csv.content.each do |named_range, csv_content|
          ctx = TransformResult.new
          ctx.column_headers = csv_content.column_headers
          csv_content.rows.each do |row|
            row = transform(named_range, ctx.column_headers, row)
            ctx.add_transformed_row(row)
          end

          trans_hash[named_range] = ctx
        end

        trans_hash
      end

      private

      # @param [Hash] column_headers
      # @param [Array] row
      # @return [Array]
      def transform(named_range, column_headers, row)
        candidates_for_named_range(named_range).each do |candidate|
          column_idx = column_headers[candidate.column]
          next unless column_idx

          existing_value = row[column_idx]
          next unless existing_value

          new_value = candidate.perform(existing_value, RowCtx.new(row, column_headers)) # transform value
          row[column_idx] = new_value
        end

        row
      end

      # @param [String] named_range
      # @return [Array<Cure::Transformation::Candidate>]
      def candidates_for_named_range(named_range)
        @candidates.select { |c| c.named_range == named_range }
      end
    end

    class RowCtx
      attr_accessor :rows, :column_headers

      def initialize(rows, column_headers)
        @rows = rows
        @column_headers = column_headers
      end
    end

    class TransformResult

      attr_accessor :transformed_rows,
                    :column_headers

      def initialize
        @transformed_rows = []
        @column_headers = {}
      end

      def add_transformed_row(row)
        @transformed_rows << row
      end
    end
  end
end
