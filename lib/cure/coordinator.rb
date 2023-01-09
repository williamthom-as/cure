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
          # 1. Extract into SQLite
          extract
          # 2. Manipulate SQLite columns
          build

          # 3. Transform each row

          with_transformer do |transformer|
            database_service.list_tables.each do |table|
              database_service.with_paged_result(table) do |row|
                puts "#{table} -> #{row}"
              end
            end
          end

          # with_transformer do |transformer|
          #   transformer.transform_content
          # end
          # 3. Transform rows from SQLite, stream to exporter
          # - This can be enhanced with a sort query, order, aggregate query etc.
          # transform(nil)
          #
          # export(transformed_csv)
          #
          # result = transformed_csv
        end
      end

      result
    end

    private

    def extract
      log_info "Beginning the extraction process..."

      extractor = Extract::Extractor.new({})
      extractor.parse_csv(config.source_file)

      log_info "...extraction complete"
    end

    def build
      log_info "Beginning the building process..."
      candidates = config.template.build.candidates
      candidates.each(&:perform)

      log_info "... building complete"
    end

    # @yieldreturn [Cure::Transformation::Transform]
    def with_transformer(&block)
      raise "No block passed" unless block

      log_info "Beginning the transformation process..."
      transformer = Cure::Transformation::Transform.new(config.template.transformations.candidates)
      yield transformer

      log_info "...transform complete"
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
