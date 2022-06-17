# frozen_string_literal: true

require "cure/log"
require "cure/file_helpers"

module Cure
  module Export
    class Exporter
      include Cure::FileHelpers
      include Log

      def self.export_ctx(ctx, output_dir, file_name)
        column_headers = ctx.column_headers.keys

        exporter = Exporter.new
        exporter.export(output_dir, file_name, ctx.transformed_rows, column_headers)
      end

      # @param [Array] rows
      # @param [Array] columns
      def export(output_dir, file_name, rows, columns)
        log_info("Exporting file to [#{output_dir}/#{file_name}] with #{rows.length} rows")

        file_contents = []
        file_contents << columns.join(",")

        rows.each do |row|
          file_contents << row.join(",")
        end

        write_to_file(
          output_dir, file_name, "csv", file_contents.join("\n")
        )
      end

      # @param [String] file_path
      # @param [String] contents
      # @param [String] file_extension
      def write_to_file(file_path, file_name, file_extension, contents)
        file_location = "#{file_path}/#{file_name || Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S%-z")}"
        clean_dir(file_path)

        with_file(file_location, file_extension) do |file|
          file.write(contents)
        end
      end

    end
  end
end
