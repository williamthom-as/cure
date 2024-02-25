# frozen_string_literal: true

module Cure
  module Extract
    class Filter

      # @return [Filter::RowHandler] row_handler
      attr_reader :row_handler

      # @return [Filter::ColumnHandler] col_handler
      attr_reader :col_handler

      def initialize
        @row_handler = RowHandler.new
        @col_handler = ColumnHandler.new
      end

      def columns(&block)
        return unless block

        @col_handler.instance_eval(&block)
      end

      def rows(&block)
        return unless block

        @row_handler.instance_eval(&block)
      end

      class ColumnHandler

        attr_reader :definitions, :source_col_positions

        def initialize
          @definitions = []
          @source_col_positions = nil
        end

        # @param [String] source
        # @param [String] as
        def with(source:, as: nil)
          @definitions << {
            source: source,
            as: as || source
          }

          self
        end

        # @param [Array<String>] columns_arr
        def set_col_positions(columns_arr)
          @source_col_positions = @definitions.each_with_object({}) do |d, hash|
            hash[columns_arr.index(d[:source])] = d
          end
        end

        # @param [Array<String>] columns_arr
        def translate_headers(columns_arr)
          return columns_arr unless has_content?

          @source_col_positions.map do |position, val|
            if position.nil?
              raise "Cannot find header position for #{val[:source]}. Please check it exists."
            end

            columns_arr[position] = val[:as]
          end
        end

        # @param [Array<String>] columns_arr
        def filter_row(columns_arr)
          return columns_arr unless has_content?

          @source_col_positions.keys.map {|k| columns_arr[k] }
        end

        # @return [TrueClass, FalseClass]
        def has_content?
          @definitions.any?
        end
      end

      class RowHandler

        attr_accessor :start_proc, :finish_proc, :including_proc

        # @param [String] where
        # @param [Hash] options
        def start(where:, options: {})
          @start_proc = {where:, options:}

          self
        end

        # @param [String] where
        # @param [Hash] options
        def finish(where:, options: {})
          @finish_proc = {where:, options:}

          self
        end

        # @param [String] where
        # @param [Hash] options
        def including(where:, options: {})
          @including_proc = {where:, options:}

          self
        end

        # @return [TrueClass, FalseClass]
        def has_content?
          !!(@start_proc || @finish_proc || @including_proc)
        end
      end
    end
  end
end
