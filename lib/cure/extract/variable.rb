# frozen_string_literal: true

module Cure
  module Extract
    class Variable
      attr_reader :name, :location

      def initialize(name, location)
        @name = name
        @location = [Extract::CsvLookup.position_for_letter(location),
                     Extract::CsvLookup.position_for_digit(location)]
      end

      def row_in_bounds?(row_idx)
        row_bounds_range.cover?(row_idx)
      end

      # @return [Range]
      def row_bounds_range
        @row_bounds_range ||= (@location&.last..@location&.last)
      end
    end
  end
end
