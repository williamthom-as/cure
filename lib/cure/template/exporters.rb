# frozen_string_literal: true

require "cure/export/base_processor"

module Cure
  class Exporters

    # @param [Array<Cure::Export::BaseProcessor>] candidates
    attr_accessor :processors

    def initialize
      @processors = []
    end

    # @param [Hash] hash
    # @return [Cure::Exporter]
    def self.from_hash(hash)
      this = Cure::Exporters.new

      if hash.key?("candidates")
        this.processors = hash["candidates"].map do |c|
          clazz_name = "Cure::Export::#{c["type"].to_s.capitalize}Processor"
          Kernel.const_get(clazz_name).new(
            c["named_range"] || Cure::Extraction.default_named_range,
            c["options"] || "{}"
          )
        end
      end

      this
    end
  end
end
