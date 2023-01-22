# frozen_string_literal: true

require "csv"
require "cure/log"
require "cure/helpers/file_helpers"

module Cure
  module Export
    class BaseProcessor
      include Log

      attr_reader :named_range

      def initialize(named_range, opts)
        @named_range = named_range
        @opts = opts
      end

      # @param [Hash]
      def process_row(_row)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def setup
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def cleanup
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    require "terminal-table"

    class TerminalProcessor < BaseProcessor

      attr_reader :table, :row_count, :processed

      def process_row(row)
        @table.headings = row.keys if @processed.zero?
        @table.add_row(row.values) if @row_count && @processed < @row_count

        @processed += 1
      end

      def setup
        # Markdown mode
        Terminal::Table::Style.defaults = {
          border_top: false,
          border_bottom: false,
          border_x: "-",
          border_y: "|",
          border_i: "|"
        }

        log_info "Exporting [#{@named_range}] to terminal."
        @row_count = @opts.fetch(:row_count, 10)
        @processed = 0
        @table = Terminal::Table.new(title: @opts[:title] || "<No Title Set>")
      end

      def cleanup
        puts @table
      end
    end

    class CsvProcessor < BaseProcessor
      include Helpers::FileHelpers

      attr_reader :csv_file

      def process_row(row)
        @csv_file.write(row.keys.to_csv) if @processed.zero?
        @csv_file.write(row.values.to_csv)

        @processed += 1
      end

      def setup
        log_info "Exporting [#{@named_range}] to CSV..."

        output_dir = @opts["directory"]
        file_name = @opts["file_name"]

        log_info("Exporting file to [#{output_dir}/#{file_name}]")
        # file_name = "#{file_name}-#{Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S%-z")}"

        path = "#{output_dir}/#{file_name}"

        clean_dir(output_dir)

        dir = File.dirname(path)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)

        path = "#{path}.csv"
        @csv_file = File.open(path, "w")
        @processed = 0
      end

      def cleanup
      ensure
        @csv_file.close
      end
    end
  end
end
