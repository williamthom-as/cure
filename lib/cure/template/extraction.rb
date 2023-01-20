# frozen_string_literal: true

module Cure
  class Extraction
    # @return [Array<Extraction::NamedRange>] named_ranges
    attr_accessor :named_ranges

    # @return [Array<Extraction::Variable>] variables
    attr_accessor :variables

    # @deprecated
    def initialize
      @named_ranges = []
      @variables = []
    end

    # We only need to get the named ranges where the candidates have specified
    # interest in them.
    #
    # @param [Array] candidate_nrs
    # @return [Array]
    # def required_named_ranges(candidate_nrs)
    #   return @named_ranges if candidate_nrs.empty?
    #
    #   @named_ranges.select { |nr| candidate_nrs.include?(nr.name) }
    # end
    #
    # def self.default_named_range
    #   "_default"
    # end
  end

  # Move to extract/named_range

end
