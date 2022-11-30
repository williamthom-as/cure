# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/helpers/file_helpers"
require "cure/helpers/perf_helpers"

require "cure/extract/extractor"
require "cure/transformation/transform"

require "rcsv"

module Cure
  # Coordinates the entire process:
  # Extract -> Build -> Transform -> Export
  class Coordinator
    include Configuration
    include Log
    include Helpers::PerfHelpers

    def initialize
      @build_candidates = config.template.build.candidates
    end

    def process
      print_memory_usage do
        print_time_spent do
          extract do |row_ctx|
            # built_csv = build(row_ctx)
            # transformed_csv = transform(built_csv)
            # export(transformed_csv)
            #
            # result = transformed_csv

            puts row_ctx
          end

        end
      end

      # result
    end

    private

    # @yield [Cure::Extract::RowContext]
    def extract(&block)
      log_info "Beginning the extraction process..."

      extractor = Extract::Extractor.new({})
      extractor.parse_csv_rows(config.source_file, &block)
    end

    # @param [Cure::Extract::RowCtx] row_ctx
    # @return [Cure::Extract::RowCtx]
    def build(row_ctx)
      log_info "Beginning the building process..."
      @build_candidates.each do |candidate|
        candidate.perform(row_ctx)
      end

      log_info "... building complete"
      row_ctx
    end

    # @param [Cure::Extract::WrappedCSV] parsed_csv
    # @return [Hash<String,Cure::Transformation::TransformResult>]
    def transform(parsed_csv)
      log_info "Beginning the transformation process..."
      transformer = Cure::Transformation::Transform.new(config.template.transformations.candidates)
      content = transformer.transform_content(parsed_csv)

      log_info "...transform complete"
      content
    end

    # @param [Hash<String,Cure::Transformation::TransformResult>] transformed_result
    # @return [Hash<String,Cure::Transformation::TransformResult>]
    def export(transformed_result)
      log_info "Beginning export process..."
      sections = config.template.exporter.sections

      sections.each do |section|
        section.perform(transformed_result)
      end

      log_info "... export complete."

      transformed_result
    end
  end
end
