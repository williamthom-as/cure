# frozen_string_literal: true

module Cure
  class Extraction
    # @param [Array<Hash>] named_ranges
    attr_accessor :named_ranges

    # @param [Array<Hash>] named_ranges
    attr_accessor :variables

    def initialize
      @named_ranges = [{
        "name" => "default",
        "section" => -1,
        "headers" => nil
      }]

      @variables = []
    end

    # @param [Hash] hash
    # @return [Cure::Extraction]
    def self.from_hash(hash)
      this = Cure::Extraction.new
      this.named_ranges.push(*hash["named_ranges"])
      this.variables.push(*hash["variables"])
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
end
