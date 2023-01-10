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
        @candidates.each do |candidate|
          column = candidate.column.to_sym

          next unless row.key?(column)

          existing_value = row[column]
          next unless existing_value

          new_value = candidate.perform(existing_value, RowCtx.new(row)) # transform value
          row[column] = new_value
        end

        row
      end
    end

    # This class looks useless, but it isn't. It exists purely to give a hook to add
    # more stuff to a strategy in the future without the method signature changing
    class RowCtx
      attr_accessor :rows

      def initialize(rows)
        @rows = rows
      end
    end
  end
end
