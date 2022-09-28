# frozen_string_literal: true

require "cure/template/transformations"
require "cure/template/extraction"
require "cure/template/dispatch"

module Cure
  class Template
    # @param [Cure::Transformations] transformations
    attr_accessor :transformations

    # @param [Cure::Extraction] extraction
    attr_accessor :extraction

    # @param [Cure::Dispatch] dispatch
    attr_accessor :dispatch

    # @param [Hash] hash
    # @return [Cure::Template]
    def self.from_hash(hash)
      this = Cure::Template.new
      this.transformations = Cure::Transformations.from_hash(hash.fetch("transformations", {}))
      this.extraction = Cure::Extraction.from_hash(hash.fetch("extraction", {}))
      this.dispatch = Cure::Dispatch.from_hash(hash.fetch("dispatch", {}))
      this
    end
  end
end
