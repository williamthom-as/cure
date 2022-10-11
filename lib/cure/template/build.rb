# frozen_string_literal: true

require "cure/builder/candidate"

module Cure
  class Build

    # @param [Array<Cure::Builder::Candidate>] candidates
    attr_accessor :candidates

    def initialize
      @candidates = []
    end

    # @param [Hash] hash
    # @return [Cure::Build]
    def self.from_hash(hash)
      this = Cure::Build.new
      if hash.key?("candidates")
        this.candidates = hash["candidates"].map { |c| Cure::Builder::Candidate.new.from_json(c) }
      end

      this
    end
  end
end
