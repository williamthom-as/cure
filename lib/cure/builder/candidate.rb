# frozen_string_literal: true

require "cure/helpers/object_helpers"
require "cure/builder/base_builder"
require "cure/extract/extractor"
require "cure/log"

module Cure
  module Builder
    # Per row, we will have a candidate for each transformation that needs to be made
    class Candidate
      include Helpers::ObjectHelpers
      include Log

      # Named range that column exists in
      # @return [String]
      attr_reader :named_range

      # Lookup column name for CSV.
      # @return [String,nil]
      attr_reader :column

      # What sort of data needs to be generated.
      # @return [Cure::Builder::BaseBuilder]
      attr_reader :action

      # @param [String,nil] column
      # @param [String] named_range
      def initialize(column, named_range)
        @column = column
        @named_range = named_range || "_default"
      end

      # @return [void]
      def perform
        @action.call
      end

      # @param [String,Symbol] _method_name
      # @param [TrueClass,FalseClass] _include_private
      # @return [TrueClass]
      def respond_to_missing?(_method_name, _include_private=false)
        true
      end

      # @param [Symbol] method_name
      # @return [Cure::Builder::BaseBuilder]
      def method_missing(method_name, args)
        klass_name = "Cure::Builder::#{method_name.to_s.capitalize}Builder"
        raise "#{method_name} is not valid" unless class_exists?(klass_name)

        @action = Kernel.const_get(klass_name).new(@named_range, @column, args[:options] || {})
      end
    end
  end
end
