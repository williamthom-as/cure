# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/database"
require "cure/helpers/file_helpers"
require "cure/helpers/perf_helpers"

require "cure/extract/extractor"
require "cure/transformation/transform"

require "rcsv"

module Cure
  # Coordinates the entire process:
  # Extract -> Build -> Transform -> Export
  class Coordinator
    include Log
    include Database
    include Configuration
    include Helpers::PerfHelpers

    # @return [Hash<String,Cure::Transformation::TransformResult>, Nil] transformed_result
    def process
      # need to check config is init'd
      result = nil
      print_memory_usage do
        print_time_spent do
          # Extract into SQLite file
          extracted_csv = extract

          # Manipulate SQLite file w new columns
          built_csv = build(extracted_csv)

          # Extract rows from a SQLite file
          # - This can be enhanced with a sort query, order, aggregate query etc.
          transformed_csv = transform(built_csv)
          export(transformed_csv)

          result = transformed_csv
        end
      end

      result
    end

    private

    # @return [Cure::Extract::WrappedCSV]
    def extract
      log_info "Beginning the extraction process..."

      extractor = Extract::Extractor.new({})
      result = extractor.extract_from_file(config.source_file)

      log_debug "Setting extracted variables to global conf for access downstream"
      config.variables = result.variables

      log_info "...extraction complete"
      result
    end

    # @param [Cure::Extract::WrappedCSV] wrapped_csv
    # @return [Cure::Extract::WrappedCSV]
    def build(wrapped_csv)
      log_info "Beginning the building process..."
      candidates = config.template.build.candidates
      candidates.each do |candidate|
        candidate.perform(wrapped_csv)
      end

      log_info "... building complete"
      wrapped_csv
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
