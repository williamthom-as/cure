# frozen_string_literal: true

require "cure/log"
require "cure/file_helpers"
require "rcsv"

module Cure
  module Transformation
    class Transform
      include Log
      include FileHelpers

      # @return [Array<Candidate>]
      attr_accessor :candidates

      # @param [Array<Candidate>] candidates
      def initialize(candidates=[])
        @candidates = candidates
      end

      # @param [Candidate] candidate
      # @return [Cure::Transformation::Transform]
      def with_candidate(candidate)
        @candidates.push(candidate)
        self
      end

      # @param [String] csv_file_location
      # @return [TransformContext]
      def extract_from_file(csv_file_location)
        file_contents = read_file(csv_file_location)
        extract_from_contents(file_contents)
      end

      # @param [String] file_contents
      # @return [TransformContext]
      def extract_from_contents(file_contents)
        ctx = TransformContext.new
        parse_content(ctx, file_contents, header: :none) do |row|
          if ctx.row_count == 1
            ctx.extract_column_headers(row)
            next
          end

          row = transform(ctx.column_headers, row)
          ctx.add_transformed_row(row)
        end

        ctx
      end

      private

      # @param [TransformContext] ctx
      # @param [String] file_contents
      # @param [Proc] _block
      # @param [Hash] opts
      # @yield [Array] row
      # @yield [TransformContext] ctx
      # @return [TransformContext]
      def parse_content(ctx, file_contents, opts={}, &_block)
        return nil unless block_given?

        Rcsv.parse(file_contents, opts) do |row|
          ctx.row_count += 1
          yield row
        end
      end

      # @param [Hash] column_headers
      # @param [Array] row
      # @return [Array]
      def transform(column_headers, row)
        @candidates.each do |candidate|
          column_idx = column_headers[candidate.column]
          next unless column_idx

          existing_value = row[column_idx]
          next unless existing_value

          new_value = candidate.perform(existing_value) # transform value
          row[column_idx] = new_value
        end

        row
      end
    end

    class TransformContext
      include FileHelpers

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
