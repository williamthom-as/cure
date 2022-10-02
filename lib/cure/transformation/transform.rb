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
        wrapped_csv.content.each_with_object({}) do |section, hash|
          ctx = TransformResult.new
          ctx.column_headers = section["content"].column_headers
          section["content"].rows.each do |row|
            row = transform(section["name"], ctx.column_headers, row)
            ctx.add_transformed_row(row)
          end

          hash[section["name"]] = ctx
        end
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

          new_value = candidate.perform(existing_value) # transform value
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

    class TransformResult

      attr_accessor :row_count,
                    :transformed_rows,
                    :column_headers

      def initialize
        @row_count = 0
        @transformed_rows = []
        @column_headers = {}
      end

      # @param [Array<String>] row
      def extract_column_headers(row)
        row.each_with_index { |column, idx| @column_headers[column] = idx }
      end

      def add_transformed_row(row)
        @transformed_rows << row
      end
    end
  end
end
