# frozen_string_literal: true

module Cure
  class Template
    # @param [Array<Candidate>] candidates
    attr_accessor :candidates

    # @param [Array<Hash>] placeholders
    # TODO: make class Placeholder
    attr_accessor :placeholders

    def initialize
      @candidates = []
      @placeholders = {}
    end

    # @param [Hash] hash
    # @return [Cure::Template]
    def self.from_hash(hash)
      this = Cure::Template.new
      this.candidates = hash["candidates"].map { |c| Cure::Transformation::Candidate.new.from_json(c) }
      this.placeholders = hash["placeholders"]
      this
    end

    # @param [Candidate] candidate
    # @return [Cure::Template]
    def with_candidate(candidate)
      @candidates.push(candidate)
      self
    end

    # @param [String] key
    # @param [Object] value
    # @return [Cure::Template]
    def with_placeholder(key, value)
      @placeholders[key.to_s] = value
      self
    end
  end
end
