# frozen_string_literal: true

require "cure/export/base_processor"
require "cure/helpers/object_helpers"
require "cure/extract/extractor"
require "cure/log"

module Cure
  module Export
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
        @named_range = Cure::Extraction.default_named_range
      end

      # @param [Hash<String,Cure::Transformation::TransformResult>] transformed_result
      # @return [Hash<String,Cure::Transformation::TransformResult>]
      def perform(transformed_result)
        return transformed_result if @processor.nil?

        @processor.process(transformed_result)
      end

      # @param [Hash] opts
      # @return [Cure::Export::Processor]
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
