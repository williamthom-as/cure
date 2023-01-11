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

      # @param [Hash]
      def process_row(_row)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      protected

      def setup
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def cleanup
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def result
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    require "terminal-table"

    class TerminalProcessor < BaseProcessor

      attr_reader :table, :row_count

      def process_row(row)
        puts row
      end

      protected

      def setup
        log_info "Exporting [#{@named_range}] to terminal."

        # title = @opts["title"] || "<No Title Set>"
        # style = @opts["style"] || {}
        # row_count = @opts["row_count"] || -1
        #
        # content = content_from_result(transformed_result)
        # rows = content.transformed_rows[0..row_count]
        #
        # log_info "Showing #{row_count} records from a total #{content.transformed_rows.size}"
        #
        # @table = Terminal::Table.new(
        #   title: title,
        #   headings: content.column_headers.keys,
        #   style: style
        # )
        #
        # puts table
      end

      def cleanup

      end

      def result
        nil
      end
    end

    class CsvProcessor < BaseProcessor
      include Helpers::FileHelpers

      # @param [Hash<String,Cure::Transformation::TransformResult>] transformed_result
      def process(transformed_result)
        log_info "Exporting [#{@named_range}] to CSV..."
        content = content_from_result(transformed_result)

        export(@opts["directory"], @opts["file_name"], content.transformed_rows, content.column_headers.keys)

        log_info "...exporting [#{@named_range}] to CSV has been completed successfully."
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
