# frozen_string_literal: true

module Cure
  class Template

    # @param [Array<Candidate>] candidates
    attr_accessor :candidates

    # @param [Array<Hash>] placeholders
    # TODO: make class Placeholder
    attr_accessor :placeholders

    # @param [Hash] hash
    # @return [Cure::Template]
    def self.from_hash(hash)
      thiz = Cure::Template.new
      thiz.candidates = hash["candidates"]
      thiz.placeholders = hash["placeholders"]
      thiz
    end

  end
end
