# frozen_string_literal: true

require "cure/log"
require "cure/file_helpers"
require "rcsv"

module Cure
  module Transformation
    class Transform
      include Log

      # @return [Array<Candidate>]
      attr_accessor :candidates

      # @param [Array<Candidate>] candidates
      def initialize(candidates)
        @candidates = candidates
      end

      # @param [String] csv_file_location
      # @return [ProcessorContext]
      def extract(csv_file_location)
        ctx = ProcessorContext.new(csv_file_location)

        parse_file(ctx, header: :none) do |row|
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

      # @param [ProcessorContext] ctx
      # @param [Proc] _block
      # @param [Hash] opts
      # @yield [Array] row
      # @yield [ProcessorContext] ctx
      # @return [ProcessorContext]
      def parse_file(ctx, opts={}, &_block)
        return nil unless block_given?

        Rcsv.parse(ctx.open_file, opts) do |row|
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

    class ProcessorContext
      include FileHelpers
      include Log

      attr_accessor :csv_file_location,
                    :row_count,
                    :transformed_rows,
                    :column_headers,
                    :column_type_definitions

      def initialize(csv_file_location)
        @csv_file_location = csv_file_location
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

      # rubocop:disable Metrics/CyclomaticComplexity
      def cast(column_header, row_property)
        return row_property unless @column_type_definitions&.key?(column_header)

        case @column_type_definitions[column_header]["data_type"]
        when "string"
          row_property.to_s
        when "decimal"
          row_property.to_f
        when "integer"
          row_property.to_i
        when "date_time"
          DateTime.parse(row_property)
        when "date"
          Date.parse(row_property)
        when nil
          row_property
        else
          row_property
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # @return [String]
      def open_file
        read_file(@csv_file_location)
      end
    end
  end
end
