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
      parsed_csv = extract(config.source_file_location)
      transformed_csv = transform(parsed_csv)
      export(transformed_csv)
    end

    private

    # @param [String] csv_file_location
    # @return [ParsedCSV]
    def extract(csv_file_location)
      log_info "Beginning the extraction process..."
      extractor = Extract::Extractor.new({})
      result = extractor.extract_from_file(csv_file_location)

      log_debug "Setting extracted variables to global conf for access downstream"
      config.variables = result.variables

      log_info "...extraction complete"
      result
    end

    def build
      "Do something later?"
    end

    # @return [Hash<String,Cure::Transformation::TransformResult>]
    # @param [ParsedCSV] parsed_csv
    def transform(parsed_csv)
      log_info "Beginning the transformation process..."
      transformer = Cure::Transformation::Transform.new(config.template.transformations.candidates)
      content = transformer.transform_content(parsed_csv)

      log_info "...transform complete"
      content
    end

    def export(transformed_result)
      log_info "Beginning export process..."
      Cure::Export::Exporter.export_result(transformed_result, config.output_dir)
      log_info "... export complete."
    end
  end
end
