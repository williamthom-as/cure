# frozen_string_literal: true

module Cure
  class Transformations
    # @param [Array<Transformation::Candidate>] candidates
    attr_accessor :candidates

    # @param [Array<Hash>] placeholders
    # TODO: make class Placeholder
    attr_accessor :placeholders

    def initialize
      @candidates = []
      @placeholders = {}
    end

    # @param [Hash] hash
    # @return [Cure::Transformations]
    def self.from_hash(hash)
      this = Cure::Transformations.new
      if hash.key? "candidates"
        this.candidates = hash["candidates"].map { |c| Cure::Transformation::Candidate.new.from_json(c) }
      end
      this.placeholders = hash["placeholders"]
      this
    end
  end
end
