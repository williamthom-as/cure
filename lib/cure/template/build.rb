# frozen_string_literal: true

require "cure/builder/candidate"

module Cure
  # This name sucks, it is just an exporter
  class Build

    # @param [Array<Hash>] candidates
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
