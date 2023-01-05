# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/extract/csv_lookup"
require "cure/helpers/file_helpers"
require "cure/helpers/perf_helpers"
require "cure/extract/named_range_processor"

require "cure/extract/wrapped_csv"

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
      # @return [WrappedCSV]
      def extract_from_file(file_proxy)
        parsed_content = parse_csv(file_proxy)
        log_info("Parsed CSV into #{parsed_content.content.length} sections.")
        parsed_content
      end

      # @param [Cure::Configuration::CsvFileProxy] file_proxy
      # @return [WrappedCSV]
      def parse_csv(file_proxy)
        nr_processor = named_range_processor
        v_processor = variable_processor
        row_count = 0

        # TOOD: Needs to insert into SQLite3 file
        # This will require a new interface to row persistence

        print_time_spent("rcsv_load") do
          print_memory_usage("rcsv_load") do
            file_proxy.with_file do |file|
              CSV.foreach(file) do |row|
                nr_processor.process_row(row_count, row)
                v_processor.process_row(row_count, row)
                row_count += 1
              end
            end
          end
        end

        log_info "[#{row_count}] total rows parsed from CSV"

        result = WrappedCSV.new
        result.content = nr_processor.results
        result.variables = v_processor.results
        result
      end

      private

      # @return [Cure::Extract::NamedRangeProcessor]
      def named_range_processor
        candidates = config.template.transformations.candidates
        candidate_nrs = config.template.extraction.required_named_ranges(candidates.map(&:named_range).uniq)
        Extract::NamedRangeProcessor.new(candidate_nrs)
      end

      # @return [Cure::Extract::VariableProcessor]
      def variable_processor
        variables = config.template.extraction.variables
        # return nil unless variables.size.positive?

        Extract::VariableProcessor.new(variables || [])
      end
    end
  end
end
