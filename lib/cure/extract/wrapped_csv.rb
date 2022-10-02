# frozen_string_literal: true

module Cure
  module Extract
    class WrappedCSV
      # @return [CSVContent]
      attr_accessor :content

      # @return [Hash]
      attr_accessor :variables

      def initialize
        @content = []
        @variables = {}
      end

      # @return [CSVContent]
      def find_named_range(named_range)
        @content.find { |x| x["name"] == named_range }.fetch("content")
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

      def row_count
        @rows.length
      end
    end
  end
end
