# frozen_string_literal: true

require "cure/extract/named_range"
require "cure/extract/variable"

module Cure
  module Dsl
    class Extraction

      attr_reader :named_ranges, :variables

      def initialize
        @named_ranges = []
        @variables = []
      end

      def named_range(name:, at:, headers: nil, ref_name: nil)
        @named_ranges << Cure::Extract::NamedRange.new(name, at, headers: headers, ref_name: ref_name)
      end

      def variable(name:, at:, ref_name: nil)
        @variables << Cure::Extract::Variable.new(name, at, ref_name: ref_name)
      end

      # @param [String] ref_name
      # @return [Array]
      def required_named_ranges(ref_name: "_default")
        # This now needs to take support multiple files. We don't want named ranges
        # for different files
        return @named_ranges if ref_name == "default"

        @named_ranges.select { |nr| nr.ref_name == ref_name }
      end

      def required_variables(ref_name: "_default")
        # This now needs to take support multiple files. We don't want named ranges
        # for different files
        return @variables if ref_name == "_default"

        @variables.select { |v| v.ref_name == ref_name }
      end
    end
  end
end
