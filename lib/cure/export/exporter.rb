# frozen_string_literal: true
require "csv"
require "cure/log"
require "cure/config"
require "cure/helpers/file_helpers"

module Cure
  module Export
    class Exporter
      include Helpers::FileHelpers
      include Configuration
      include Log

      # @param [Array<Cure::Transform::TransformResult>] result
      def self.export_result(results, output_dir)
        exporter = Exporter.new(output_dir)
        exporter.export_results(results)
      end

      attr_reader :output_dir

      def initialize(output_dir)
        @output_dir = output_dir
      end

      # @param [Array<Cure::Transform::TransformResult>] result
      def export_results(result)
        export_ranges = config.template.dispatch.named_ranges

        export_ranges.each do |range|
          named_range = range["named_range"]
          unless result.has_key?(named_range)
            raise "Missing named range - #{range} from candidates [#{result.keys.join(", ")}]"
          end

          data = result[named_range]
          column_headers = data.column_headers.keys
          export(@output_dir, range["file_name"], data.transformed_rows, column_headers)
        end
      end

      # @param [Array] rows
      # @param [Array] columns
      def export(output_dir, file_name, rows, columns)
        file_name = "#{file_name}-#{Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S%-z")}"

        log_info("Exporting file to [#{output_dir}/#{file_name}] with #{rows.length} rows")

        file_contents = []
        file_contents << columns.join(",").to_s
        file_contents << rows.map(&:to_csv).join

        write_to_file(
          output_dir, file_name, "csv", file_contents.join("\n")
        )
      end

      # @param [String] file_path
      # @param [String] contents
      # @param [String] file_extension
      def write_to_file(file_path, file_name, file_extension, contents)
        file_location = "#{file_path}/#{file_name}"
        clean_dir(file_path)

        with_file(file_location, file_extension) do |file|
          file.write(contents)
        end
      end
    end
  end
end

