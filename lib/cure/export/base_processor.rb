# frozen_string_literal: true

require "csv"
require "cure/log"
require "cure/helpers/file_helpers"

module Cure
  module Export
    class BaseProcessor
      include Log

      def initialize(named_range, opts)
        @named_range = named_range
        @opts = opts
      end

      # @param [Hash<String,Cure::Transformation::TransformResult>] _transformed_result
      # @return [Hash<String,Cure::Transformation::TransformResult>]
      def process(_transformed_result)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class CsvProcessor < BaseProcessor
      include Helpers::FileHelpers

      # @param [Hash<String,Cure::Transformation::TransformResult>] transformed_result
      # @return [Hash<String,Cure::Transformation::TransformResult>]
      def process(transformed_result)
        content = transformed_result.fetch(@named_range, nil)
        unless content
          raise "Missing named range - #{@named_range} from candidates [#{transformed_result.keys.join(", ")}]"
        end

        export(@opts["directory"], @opts["file_name"], content.transformed_rows, content.column_headers.keys)
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