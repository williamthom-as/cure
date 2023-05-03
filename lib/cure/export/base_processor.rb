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

      attr_reader :table, :limit_rows, :processed

      def process_row(row)
        @table.headings = row.keys if @processed.zero?
        @table.add_row(row.values) if @limit_rows && @processed < @limit_rows

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
        @limit_rows = @opts.fetch(:limit_rows, 10)
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

        output_dir = @opts[:directory]
        file_name = @opts[:file_name]

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
        log_info File.basename(@csv_file)
        @csv_file.close
      end
    end

    class ChunkCsvProcessor < BaseProcessor
      include Helpers::FileHelpers

      attr_reader :current_csv_file,
                  :file_name_prefix,
                  :directory,
                  :chunk_size,
                  :include_headers,
                  :row_count

      def process_row(row)
        chunked_file_handler do |csv_file|
          if @processed.zero? || (@processed % @chunk_size).zero? || (@processed % @chunk_size).zero?
            csv_file.write(row.keys.to_csv)
          end

          csv_file.write(row.values.to_csv)
          @processed += 1
        end
      end

      def setup
        log_info "Exporting [#{@named_range}] to CSV..."

        extract_opts

        log_info("Exporting file to [#{@output_dir}/#{@file_name_prefix}]")

        clean_dir(@output_dir)

        dir = File.dirname("#{@output_dir}/#{@file_name_prefix}")
        FileUtils.mkdir_p(dir) unless File.directory?(dir)

        @processed = 0
        @current_chunk = 0
      end

      def cleanup
      ensure
        @current_csv_file.close
      end

      def extract_opts
        @output_dir = @opts[:directory]
        @file_name_prefix = @opts[:file_name_prefix]
        @directory = @opts[:directory]
        @chunk_size = @opts[:chunk_size]
        @include_headers = @opts.fetch(:include_headers, true)
      end

      def chunked_file_handler(&block)
        raise "No block" unless block

        if @processed.zero? || (@processed % @chunk_size).zero?
          @current_csv_file&.close

          @current_chunk += 1
          @current_csv_file = File.open(current_file_path, "w")
        end

        yield @current_csv_file
      end

      def current_file_path
        "#{@output_dir}/#{@current_chunk}-#{@file_name_prefix}.csv"
      end
    end

    class YieldRowProcessor < BaseProcessor
      attr_reader :proc

      def process_row(row)
        @proc.call(row)
      end

      def setup
        @proc = @opts.fetch(:proc)
      end

      def cleanup; end
    end
  end
end
