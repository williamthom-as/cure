# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/csv_lookup"
require "cure/helpers/file_helpers"
require "cure/helpers/perf_helpers"
require "cure/extract/named_range_processor"

require "cure/extract/wrapped_csv"
require "cure/extract/row_context"

require "csv"
require "objspace"

module Cure
  module Extract
    class Extractor
      include Log
      include Configuration
      include Helpers::FileHelpers
      include Helpers::PerfHelpers

      # @param [Hash] opts
      attr_reader :opts

      # @param [Hash] opts
      def initialize(opts)
        @opts = opts
      end

      # @param [Cure::Configuration::CsvFileProxy] file_proxy
      # @@yield [RowContext]
      def parse_csv_rows(file_proxy, &_block)
        nr_processor = named_range_processor
        row_count = -1
        headers = nil

        # TODO: Add cache here to collect rows until headers hit and do a flush
        print_time_spent("rcsv_load") do
          print_memory_usage("rcsv_load") do
            file_proxy.with_file do |file|
              CSV.foreach(file) do |row|
                row_count += 1
                row = nr_processor.process_row(row_count, row)

                next unless row

                if row[0] == :headers
                  headers = row[1]
                  next
                end

                yield RowContext.new(headers, row[1])
              end
            end
          end
        end

        log_info "[#{row_count}] total rows parsed from CSV"
      end

      private

      # @return [Cure::Extract::NamedRangeProcessor]
      def named_range_processor
        Extract::NamedRangeProcessor.new(config.template.extraction.named_range)
      end
    end
  end
end
