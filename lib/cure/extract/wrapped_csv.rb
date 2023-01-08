# frozen_string_literal: true

module Cure
  module Extract
    # Deprecated
    class WrappedCSV
      # @return [Hash<String,CSVContent>]
      attr_accessor :content

      # @return [Hash]
      attr_accessor :variables

      def initialize
        @content = []
        @variables = {}
      end

      # @return [CSVContent]
      def find_named_range(named_range)
        nr = @content[named_range]

        raise "Missing named range for [#{named_range}]. Candidates are [#{@content.values.join(", ")}]" unless nr

        nr
      end
    end

    class CSVContent
      attr_accessor :rows,
                    :column_headers

      def initialize
        @rows = []
        @column_headers = {}
      end

      # @param [Array<String>] row
      def extract_column_headers(row)
        row.each_with_index { |column, idx| @column_headers[column] = idx }
      end

      def add_rows(rows)
        @rows.concat(rows)
      end

      def add_row(row)
        @rows << row
      end

      def add_column_key(key)
        @column_headers[key] = @column_headers.length
      end

      def remove_column_key(key)
        remove_idx = column_headers[key]

        @column_headers.delete(key)
        @column_headers.each do |k, val|
          @column_headers[k] -= 1 if val > remove_idx
        end

        remove_idx
      end

      def row_count
        @rows.length
      end
    end
  end
end
