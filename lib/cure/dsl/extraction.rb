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

      def named_range(name:, at:, headers: nil, &block)
        candidate = Cure::Extract::NamedRange.new(name, at, headers)
        mappings = Cure::Extract::Mappings.new

        if block_given?
          mappings.instance_exec(&block)
          candidate.mappings = mappings
        end

        @named_ranges << candidate
      end

      def variable(name:, at:)
        @variables << Cure::Extract::Variable.new(name, at)
      end

      # We only need to get the named ranges where the candidates have specified
      # interest in them.
      #
      # @param [Array] candidate_nrs
      # @return [Array]
      def required_named_ranges(candidate_nrs)
        @named_ranges = [Cure::Extract::NamedRange.default_named_range] if @named_ranges.empty?
        return @named_ranges if candidate_nrs.empty?

        @named_ranges.select { |nr| candidate_nrs.include?(nr.name) }
      end
    end
  end
end
