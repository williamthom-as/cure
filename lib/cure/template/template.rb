# frozen_string_literal: true

require "cure/template/transformations"
require "cure/template/extraction"
require "cure/template/build"
require "cure/template/exporter"

module Cure
  class Template
    # @return [Cure::Transformations] transformations
    attr_accessor :transformations

    # @return [Cure::Extraction] extraction
    attr_accessor :extraction

    # @return [Cure::Build]
    attr_accessor :build

    # @return [Cure::Exporter]
    attr_accessor :exporter

    # @param [Hash] hash
    # @return [Cure::Template]
    def self.from_hash(hash) # rubocop:disable Metrics/AbcSize
      this = Cure::Template.new
      this.transformations = Cure::Transformations.from_hash(hash.fetch("transformations", {}))
      this.extraction = Cure::Extraction.from_hash(hash.fetch("extraction", {}))
      this.build = Cure::Build.from_hash(hash.fetch("build", {}))
      this.exporter = Cure::Exporter.from_hash(hash.fetch("exporter", {}))

      this
    end

  end
end
