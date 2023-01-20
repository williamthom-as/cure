# frozen_string_literal: true

require "cure/helpers/object_helpers"
require "cure/strategy/imports"
require "cure/generator/imports"
require "cure/extract/extractor"
require "cure/log"

module Cure
  module Transformation
    # Per row, we will have a candidate for each transformation that needs to be made
    class Candidate
      include Helpers::ObjectHelpers
      include Log

      # Named range that column exists in
      # @return [String]
      attr_reader :named_range

      # Lookup column name for CSV.
      # @return [String]
      attr_reader :column

      # What sort of data needs to be generated.
      # @return [List<Translation>]
      attr_reader :translations

      # @return [Translation]
      attr_reader :no_match_translation

      def initialize(column, named_range: Cure::Extraction.default_named_range)
        @column = column
        @named_range = named_range

        @translations = []
        @no_match_translation = nil
      end

      # @param [String] source_value
      # @param [RowCtx] row_ctx
      # @return [String]
      # Transforms the existing value
      def perform(source_value, row_ctx)
        value = source_value

        @translations.each do |translation|
          temp = translation.extract(value, row_ctx)
          value = temp if temp
        end

        if value == source_value
          log_debug("No translation made for #{value} [#{source_value}]")
          value = @no_match_translation&.extract(source_value, row_ctx)
          log_debug("Translated to #{value} from [#{source_value}]")
        end

        value
      end

      def with_translation(&block)
        translation = Translation.new
        @translations << translation
        translation.instance_exec(&block)
      end

      def if_no_match(&block)
        no_match_translation = Translation.new
        @no_match_translation = no_match_translation
        no_match_translation.instance_exec(&block)
      end
    end

    class Translation
      include Helpers::ObjectHelpers

      # What sort of replacement is done, full/random/lookup/partial.
      # @return [Strategy::BaseStrategy]
      attr_reader :strategy

      # What sort of data needs to be generated.
      # @return [Generator::BaseGenerator]
      attr_reader :generator

      # @param [String] source_value
      # @return [String]
      def extract(source_value, row_ctx)
        @strategy.extract(source_value, row_ctx, @generator)
      end

      def replace(name, **options)
        klass_name = "Cure::Strategy::#{name.to_s.capitalize}Strategy"
        raise "#{name} is not valid" unless class_exists?(klass_name)

        @strategy = Kernel.const_get(klass_name).new(options)
        self
      end

      def with(name, **options)
        klass_name = "Cure::Generator::#{name.to_s.capitalize}Generator"
        raise "#{name} is not valid" unless class_exists?(klass_name)

        @generator = Kernel.const_get(klass_name).new(options)
        self
      end

      def class_exists?(klass_name)
        klass = Module.const_get(klass_name)
        klass.is_a?(Class)
      rescue NameError
        false
      end

    end
  end
end
