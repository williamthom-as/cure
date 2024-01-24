# frozen_string_literal: true

module Cure
  module Extract
    class NamedRange

      def self.default_named_range(name: nil)
        name ||= "_default"

        new(name, -1)
      end

      attr_accessor :filter

      attr_reader :name, :section, :headers, :ref_name

      # This is complex purely to support headers not being the 0th row.
      # A template can specify that the headers row be completely disconnected
      # from the content, thus we have three bounds:
      # - Content bounds
      # - Header bounds
      # - Sheet bounds (headers AND content)
      def initialize(name, section, headers: nil, ref_name: nil)
        @name = name
        @section = Extract::CsvLookup.array_position_lookup(section)
        @headers = calculate_headers(headers)
        @ref_name = ref_name || "_default"
      end

      # @param [Integer] row_idx
      # @return [TrueClass, FalseClass]
      def row_in_bounds?(row_idx)
        row_bounds_range.cover?(row_idx)
      end

      # @param [Integer] row_idx
      # @return [TrueClass, FalseClass]
      def header_in_bounds?(row_idx)
        header_bounds_range.cover?(row_idx)
      end

      # @param [Integer] row_idx
      # @return [TrueClass, FalseClass]
      def content_in_bounds?(row_idx)
        content_bounds_range.cover?(row_idx)
      end

      # @return [Range]
      def row_bounds_range
        @row_bounds_range ||= (row_bounds&.first..row_bounds&.last)
      end

      def row_bounds
        @row_bounds ||= content_bounds.concat(header_bounds).uniq.minmax
      end

      # @return [Range]
      def content_bounds_range
        @content_bounds_range ||= (content_bounds[0]..content_bounds[1])
      end

      def content_bounds
        @content_bounds ||= @section[2..3]
      end

      # @return [Range]
      def header_bounds_range
        @header_bounds_range ||= (header_bounds&.first..header_bounds&.last)
      end

      def header_bounds
        @header_bounds ||= @headers[2..3]
      end

      def with_filter(&block)
        @filter = Filter.new

        yield @filter.rows, @filter.columns if block_given?
      end

      private

      def calculate_headers(headers)
        return Extract::CsvLookup.array_position_lookup(headers) if headers

        [@section[0], @section[1], @section[2], @section[2]]
      end
    end

    class Filter

      attr_reader :rows, :columns

      def initialize
        @rows = Rows.new
        @columns = Columns.new
      end

      class Columns

        attr_reader :definitions

        def initialize
          @definitions = []
        end

        def with(source:, as: nil)
          @definitions << {
            source: source,
            as: as || source
          }

          self
        end
      end

      class Rows

        attr_accessor :start_proc, :finish_proc, :including_proc

        def start(where:, options: {})
          @start_proc = {where:, options:}

          self
        end

        def finish(where:, options: {})
          @finish_proc = {where:, options:}

          self
        end

        def including(where:, options: {})
          @including_proc = {where:, options:}

          self
        end
      end
    end
  end
end
