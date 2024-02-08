# frozen_string_literal: true

require "cure/log"
require "cure/helpers/file_helpers"
require "cure/config"
require "cure/extract/extractor"

require "rcsv"

module Cure
  module Transformation
    # Operational file for conducting transforms
    class Transform
      include Log
      include Helpers::FileHelpers
      include Configuration

      # @return [Array<Candidate>]
      attr_accessor :candidates

      # @param [Array<Candidate>] candidates
      def initialize(candidates)
        @candidates = candidates
      end

      # @param [Hash] row
      # @return [Hash]
      def transform(row)
        original_row = row.dup

        @candidates.each do |candidate|
          column = candidate.column.to_sym

          next unless row.key?(column)

          existing_value = row[column]
          next if existing_value.nil? && candidate.ignore_empty

          new_value = candidate.perform(existing_value, RowCtx.new(row, original_row: original_row)) # transform value
          row[column] = new_value
        end

        remove_system_columns(row)
      end

      def remove_system_columns(row)
        row.delete(:_id)
        row
      end
    end

    # This class looks useless, but it isn't. It exists purely to give a hook to add
    # more stuff to a strategy in the future without the method signature changing
    class RowCtx
      attr_accessor :row, :original_row

      def initialize(row, original_row: nil)
        @row = row
        @original_row = original_row
      end
    end
  end
end
