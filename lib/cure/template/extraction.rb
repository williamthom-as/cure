# frozen_string_literal: true

module Cure
  class Extraction
    # @param [Array<Hash>] named_ranges
    attr_accessor :named_ranges

    def initialize
      @named_ranges = [default_value]
    end

    # @param [Hash] hash
    # @return [Cure::Extraction]
    def self.from_hash(hash)
      this = Cure::Extraction.new
      this.named_ranges.push(*hash["named_ranges"])
      this
    end

    def default_value
      {
        "name" => "default",
        "section" => -1
      }
    end
  end
end
