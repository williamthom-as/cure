# frozen_string_literal: true

require "cure/export/base_processor"
require "cure/helpers/object_helpers"
require "cure/extract/extractor"
require "cure/log"

module Cure
  module Export
    # This is a shit name
    class Section
      include Helpers::ObjectHelpers
      include Log

      # Named range that column exists in
      # @return [String]
      attr_accessor :named_range

      # What sort of data needs to be generated.
      # @return [Cure::Export::Processor]
      attr_reader :processor

      def initialize
        @named_range = Cure::Extraction.default_named_range # TODO: this needs to not be hardcoded
      end

      # @param [Hash] row
      # @return [Hash]
      def perform(row)
        @processor.process_row(row)
      end

      # @param [Hash] opts
      # @return [Cure::Export::BaseProcessor]
      def processor=(opts)
        clazz_name = "Cure::Export::#{opts["type"].to_s.capitalize}Processor"
        processor = Kernel.const_get(clazz_name).new(
          @named_range,
          opts["options"] || "{}"
        )

        @processor = processor
      end
    end
  end
end
