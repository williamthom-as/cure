# frozen_string_literal: true

require "cure/template/transformations"
require "cure/template/extraction"
require "cure/template/build"
require "cure/template/exporters"

module Cure
  class Template
    # @return [Cure::Transformations] transformations
    attr_accessor :transformations

    # @return [Cure::Extraction] extraction
    attr_accessor :extraction

    # @return [Cure::Build]
    attr_accessor :build

    # @return [Cure::Exporters]
    attr_accessor :exporters

    # @param [Hash] hash
    # @return [Cure::Template]
    def self.from_hash(hash)
      this = Cure::Template.new
      this.transformations = Cure::Transformations.from_hash(hash.fetch("transformations", {}))
      this.extraction = Cure::Extraction.from_hash(hash.fetch("extraction", {}))
      this.build = Cure::Build.from_hash(hash.fetch("build", {}))
      this.exporters = Cure::Exporters.from_hash(hash.fetch("exporters", {}))

      this
    end

  end
end
