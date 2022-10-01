# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/helpers/file_helpers"

require "cure/extract/extractor"
require "cure/transformation/transform"
require "cure/export/exporter"

require "rcsv"

module Cure
  # Coordinates the entire process:
  # Extract -> Build -> Transform -> Export
  class Coordinator
    include Configuration
    include Log

    def process
      # need to check config is init'd

      extracted_csv = extract
      built_csv = build(extracted_csv)
      transformed_csv = transform(built_csv)
      export(transformed_csv)
    end

    private

    # @return [Cure::Extract::WrappedCSV]
    def extract
      log_info "Beginning the extraction process..."

      extractor = Extract::Extractor.new({})
      result = extractor.extract_from_file(config.source_file_location)

      log_debug "Setting extracted variables to global conf for access downstream"
      config.variables = result.variables

      log_info "...extraction complete"
      result
    end

    # @param [Cure::Extract::WrappedCSV] wrapped_csv
    def build(wrapped_csv)
      log_info "Beginning the building process..."
      log_info "... building complete"
      wrapped_csv
    end

    # @return [Hash<String,Cure::Transformation::TransformResult>]
    # @param [Cure::Extract::WrappedCSV] parsed_csv
    def transform(parsed_csv)
      log_info "Beginning the transformation process..."
      transformer = Cure::Transformation::Transform.new(config.template.transformations.candidates)
      content = transformer.transform_content(parsed_csv)

      log_info "...transform complete"
      content
    end

    # @return [Hash<String,Cure::Transformation::TransformResult>]
    def export(transformed_result)
      log_info "Beginning export process..."
      Cure::Export::Exporter.export_result(transformed_result, config.output_dir)
      log_info "... export complete."
    end
  end
end
