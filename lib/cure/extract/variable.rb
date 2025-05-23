# frozen_string_literal: true

module Cure
  module Extract
    class Variable
      attr_reader :name, :location, :ref_name

      def initialize(name, location, ref_name: "_default")
        @name = name
        @location = [
          Extract::CsvLookup.position_for_letter(location),
          Extract::CsvLookup.position_for_digit(location, if_digit_nil: 1_023)
        ]
        @ref_name = ref_name
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
