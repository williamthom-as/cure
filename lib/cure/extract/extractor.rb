# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/database"
require "cure/extract/csv_lookup"
require "cure/helpers/file_helpers"
require "cure/helpers/perf_helpers"
require "cure/extract/named_range_processor"

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

      def parse_csv(file, ref_name:)
        nr_processor = named_range_processor(ref_name: ref_name)
        v_processor = variable_processor(ref_name: ref_name)
        row_count = 0

        database_service.with_transaction do
          CSV.foreach(file, liberal_parsing: true) do |row|
            nr_processor.process_row(row_count, row)
            v_processor.process_row(row_count, row)
            row_count += 1

            log_info "#{row_count} rows processed [#{Time.now}]" if (row_count % 1_000).zero?
          end

          nr_processor.after_process
        end

        log_info "[#{row_count}] total rows parsed from CSV"
      end

      private

      # @return [Cure::Extract::NamedRangeProcessor]
      def named_range_processor(ref_name:)
        candidate_nrs = config.template.extraction.required_named_ranges(ref_name: ref_name)

        if candidate_nrs.empty?
          candidate_nrs = [
            Cure::Extract::NamedRange.default_named_range(name: ref_name)
          ]
        end

        Extract::NamedRangeProcessor.new(database_service, candidate_nrs)
      end

      # @return [Cure::Extract::VariableProcessor]
      def variable_processor(ref_name:)
        variables = config.template.extraction.required_variables(ref_name: ref_name)
        Extract::VariableProcessor.new(database_service, variables || [])
      end
    end
  end
end
