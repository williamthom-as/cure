# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/database"
require "cure/helpers/file_helpers"
require "cure/helpers/perf_helpers"

require "cure/extract/extractor"
require "cure/transformation/transform"
require "cure/export/manager"

require "rcsv"

module Cure
  # Coordinates the entire process:
  # Extract -> Build -> Transform -> Export
  class Coordinator
    include Log
    include Database
    include Configuration
    include Helpers::PerfHelpers

    def process
      # need to check config is init'd
      result = nil
      print_memory_usage do
        print_time_spent do
          # 1. Extract into SQLite
          extract
          # 2. Manipulate SQLite columns
          build
          # 3. Validate columns
          validate


          # 3. Transform each row
          database_service.list_tables.each do |table|
            with_transformer(table) do |transformer|
              with_exporters(table) do |exporters|
                database_service.with_paged_result(table) do |row|
                  transformed_row = transformer.transform(row)
                  exporters.each do |exporter|
                    # 4. Export
                    exporter.process_row(transformed_row)
                  end
                end
              end
            end
          end
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
      candidates = config.template.builder.candidates
      candidates.each(&:perform)

      log_info "... building complete"
    end

    # @yieldreturn [Cure::Transformation::Transform]
    def with_transformer(named_range, &block)
      raise "No block passed" unless block

      log_info "Beginning the transformation process..."
      candidates = config.template.transformations.candidates.select { |c| c.named_range == named_range.to_s }
      transformer = Cure::Transformation::Transform.new(candidates)
      yield transformer

      log_info "...transform complete"
    end

    # @yieldreturn [Cure::Export::Section]
    def with_exporters(named_range, &block)
      raise "No block passed" unless block

      log_info "Beginning export process..."
      processors = config.template.exporters.processors.select { |c| c.named_range.to_s == named_range.to_s }
      manager = Cure::Export::Manager.new(named_range, processors)

      manager.with_processors(&block)

      log_info "...export complete"
    end

    # @deprecated - I think?
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
