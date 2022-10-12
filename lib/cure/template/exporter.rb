# frozen_string_literal: true

require "cure/export/section"

module Cure
  class Exporter

    # @param [Array<Cure::Export::Section>] sections
    attr_accessor :sections

    def initialize
      @sections = []
    end

    # @param [Hash] hash
    # @return [Cure::Exporter]
    def self.from_hash(hash)
      this = Cure::Exporter.new
      this.sections = hash["sections"].map { |c| Cure::Export::Section.new.from_json(c) } if hash.key?("sections")
      this
    end
  end
end
