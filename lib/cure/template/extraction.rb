# frozen_string_literal: true

module Cure
  class Extraction
    # @return [Array<Extraction::NamedRange>] named_ranges
    attr_accessor :named_ranges

    # @return [Array<Hash>] variables
    attr_accessor :variables

    def initialize
      @named_ranges = [NamedRange.new("default", -1, nil)]
      @variables = []
    end

    # @param [Hash] hash
    # @return [Cure::Extraction]
    def self.from_hash(hash)
      this = Cure::Extraction.new
      this.variables.push(*hash["variables"]) if hash.key? "variables"
      if hash.key? "named_ranges"
        this.named_ranges = hash["named_ranges"].map { |nr| NamedRange.new(nr["name"], nr["section"], nr["headers"]) }
      end

      this
    end

    # We only need to get the named ranges where the candidates have specified
    # interest in them.
    #
    # @param [Array] candidate_nrs
    # @return [Array]
    def required_named_ranges(candidate_nrs)
      return @named_ranges if candidate_nrs.empty?

      @named_ranges.select { |nr| candidate_nrs.include?(nr["name"]) }
    end
  end

  class NamedRange

    attr_reader :name, :section, :headers

    def initialize(name, section, header)
      @name = name
      @section = Extract::CsvLookup.array_position_lookup(section)
      @headers = Extract::CsvLookup.array_position_lookup(header) || 0..-1
    end

    # @param [Integer] row_idx
    # @return [TrueClass, FalseClass]
    def row_in_bounds?(row_idx)
      row_bounds_range.cover?(row_idx)
    end

    # @return [Array, nil]
    def row_bounds
      @row_bounds ||= @section[2..3]
    end

    def header_bounds

    end

    # @return [Range]
    def row_bounds_range
      @row_bounds_range ||= (row_bounds&.first..row_bounds&.last)
    end

  end
end
