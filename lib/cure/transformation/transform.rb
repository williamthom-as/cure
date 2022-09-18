# frozen_string_literal: true

require "cure/log"
require "cure/file_helpers"
require "cure/config"
require "cure/cleanup/extractor"

require "rcsv"

module Cure
  module Transformation
    # Operational file for conducting transforms
    class Transform
      include Log
      include FileHelpers
      include Configuration

      # @return [Array<Candidate>]
      attr_accessor :candidates

      # @param [Array<Candidate>] candidates
      def initialize(candidates)
        @candidates = candidates
      end

      # @param [String] csv_file_location
      # @return [Array<TransformResult>]
      def extract_from_file(csv_file_location)
        file_contents = read_file(csv_file_location)
        extract_from_contents(file_contents)
      end

      # @param [String] file_contents
      # @return [Array<TransformResult>] # make this transformation results?
      def extract_from_contents(file_contents)
        parsed_content = parse_csv(file_contents, header: :none)

        log_info("Parsed CSV into #{parsed_content.length} sections.")

        parsed_content.map do |section|
          ctx = TransformResult.new
          section["rows"].each do |row|
            ctx.row_count += 1

            if ctx.row_count == 1
              ctx.extract_column_headers(row)
              next
            end

            row = transform(section["name"], ctx.column_headers, row)
            ctx.add_transformed_row(row)
          end

          ctx
        end
      end

      private

      # @param [String] file_contents
      # @param [Hash] opts
      # @return [Array<Hash>]
      def parse_csv(file_contents, opts={})
        csv_rows = []
        Rcsv.parse(file_contents, opts) { |row| csv_rows << row }

        extractor = Cure::Cleanup::Extractor.new({})

        # Use only the NR's that are defined from the candidates list
        config.template.extraction.required_named_ranges(@candidates.map(&:named_range).uniq).map do |nr|
          {
            "rows" => extractor.extract_from_rows(csv_rows, nr["section"]),
            "name" => nr["name"]
          }
        end
      end

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
