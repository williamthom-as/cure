# frozen_string_literal: true

require "cure/log"
require "cure/file_helpers"

module Cure
  module Export
    class Exporter
      include Cure::FileHelpers

      # @param [Array] rows
      # @param [Hash] column_headers
      def export(output_dir, file_name, rows, column_headers)
        file_contents = []
        file_contents << column_headers.keys.join(",")

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
        with_file(file_location, file_extension) do |file|
          file.write(contents)
        end
      end

    end
  end
end
