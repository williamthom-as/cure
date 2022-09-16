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
      this.candidates = hash["candidates"].map { |c| Cure::Transformation::Candidate.new.from_json(c) }
      this.placeholders = hash["placeholders"]
      this
    end

    # @param [Transformation::Candidate] candidate
    # @return [Cure::Transformations]
    def with_candidate(candidate)
      @candidates.push(candidate)
      self
    end

    # @param [String] key
    # @param [Object] value
    # @return [Cure::Transformations]
    def with_placeholder(key, value)
      @placeholders[key.to_s] = value
      self
    end
  end
end
