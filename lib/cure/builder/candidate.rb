# frozen_string_literal: true

require "cure/helpers/object_helpers"
require "cure/builder/base_builder"
require "cure/log"

module Cure
  module Builder
    # Per row, we will have a candidate for each transformation that needs to be made
    class Candidate
      include Helpers::ObjectHelpers
      include Log

      # Named range that column exists in
      # @return [String]
      attr_accessor :named_range

      # Lookup column name for CSV.
      # @return [String]
      attr_accessor :column

      # What sort of data needs to be generated.
      # @return [Cure::Builder::BaseBuilder]
      attr_reader :action

      def initialize
        @named_range = "default"
      end

      # @param [Cure::Extract::WrappedCSV] wrapped_csv
      def perform(wrapped_csv)
        return wrapped_csv if @action.nil?

        @action.process(wrapped_csv)
      end

      # @param [Hash] opts
      # @return [Cure::Builder::BaseBuilder]
      def action=(opts)
        clazz_name = "Cure::Builder::#{opts["type"].to_s.capitalize}Builder"
        action = Kernel.const_get(clazz_name).new(
          @named_range,
          @column,
          opts["options"] || "{}"
        )

        @action = action
      end
    end
  end
end
