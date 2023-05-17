# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/database"
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
      include Database
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
      def parse_csv(file_proxy)
        nr_processor = named_range_processor
        v_processor = variable_processor
        row_count = 0

        print_time_spent("rcsv_load") do
          print_memory_usage("rcsv_load") do
            file_proxy.with_file do |file|
              database_service.with_transaction do
                CSV.foreach(file) do |row|
                  nr_processor.process_row(row_count, row)
                  v_processor.process_row(row_count, row)
                  row_count += 1

                  log_info "#{row_count} rows processed [#{Time.now}]" if (row_count % 1_000).zero?
                end

                nr_processor.after_process
              end
            end
          end
        end

        log_info "[#{row_count}] total rows parsed from CSV"
      end

      private

      # @return [Cure::Extract::NamedRangeProcessor]
      def named_range_processor
        candidates = config.template.transformations.candidates
        candidate_nrs = config.template.extraction.required_named_ranges(candidates.map(&:named_range).uniq)
        Extract::NamedRangeProcessor.new(database_service, candidate_nrs)
      end

      # @return [Cure::Extract::VariableProcessor]
      def variable_processor
        variables = config.template.extraction.variables
        Extract::VariableProcessor.new(database_service, variables || [])
      end
    end
  end
end
