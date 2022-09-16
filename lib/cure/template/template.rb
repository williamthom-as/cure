# frozen_string_literal: true

require "cure/template/transformations"
require "cure/template/extraction"

module Cure
  class Template
    # @param [Cure::Transformations] transformations
    attr_accessor :transformations

    # @param [Cure::Extraction] extraction
    attr_accessor :extraction

    # @param [Hash] hash
    # @return [Cure::Template]
    def self.from_hash(hash)
      this = Cure::Template.new
      this.transformations = Cure::Transformations.from_hash(hash.fetch("transformations", {}))
      this.extraction = Cure::Extraction.from_hash(hash.fetch("extraction", {}))
      this
    end
  end
end
