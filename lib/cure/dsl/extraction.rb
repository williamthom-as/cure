# frozen_string_literal: true

require "cure/extract/named_range"
require "cure/extract/variable"

module Cure
  module Dsl
    class Extraction

      attr_reader :named_ranges, :variables, :sample_rows

      def initialize
        @named_ranges = []
        @variables = []
      end

      def named_range(name:, at: -1, headers: nil, ref_name: nil, placeholder: false, &block)
        named_range = Extract::NamedRange.new(name, at,
          headers: headers,
          ref_name: ref_name,
          placeholder: placeholder
        )

        if block_given?
          named_range.filter.instance_eval(&block)
        end

        @named_ranges << named_range
      end

      def variable(name:, at:, ref_name: nil)
        @variables << Cure::Extract::Variable.new(name, at, ref_name: ref_name)
      end

      def sample(rows: nil)
        @sample_rows = rows
      end

      # @param [String] ref_name
      # @return [Array]
      def required_named_ranges(ref_name: "_default")
        # This now needs to take support multiple files. We don't want named ranges
        # for different files
        return @named_ranges if ref_name == "default"

        @named_ranges.select { |nr| nr.ref_name == ref_name && nr.placeholder == false }
      end

      # @param [String] ref_name
      # @return [Array]
      def required_variables(ref_name: "_default")
        # This now needs to take support multiple files. We don't want named ranges
        # for different files
        return @variables if ref_name == "_default"

        @variables.select { |v| v.ref_name == ref_name }
      end
    end
  end
end
