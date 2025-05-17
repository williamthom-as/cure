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

      attr_reader :ignore_empty

      def initialize(
        column,
        named_range: Cure::Extraction.default_named_range,
        options: {}
      )
        @column = column
        @named_range = named_range
        @ignore_empty = options.fetch(:ignore_empty, false)

        @translations = []
        @no_match_translation = nil
      end

      # @param [String,nil] source_value
      # @param [RowCtx] row_ctx
      #
      # @return [String,nil]
      # Transforms the existing value
      def perform(source_value, row_ctx)
        value = source_value

        @translations.each do |translation|
          temp = translation.extract(@column, value, row_ctx)
          value = temp if temp
        end

        if value == source_value && @no_match_translation
          log_trace("No translation made for #{value} [#{source_value}]")
          value = @no_match_translation.extract(@column, source_value, row_ctx)
          log_trace("Translated to #{value} from [#{source_value}]")
        end

        value
      end

      def with_translations(translations)
        @translations = translations
        self
      end

      def with_no_match_translation(no_match_translation)
        @no_match_translation = no_match_translation
        self
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

      def initialize(strategy, generator)
        @strategy = strategy
        @generator = generator
      end

      # @param [String] source_column
      # @param [String,nil] source_value
      # @return [String]
      def extract(source_column, source_value, row_ctx)
        @strategy.extract(source_column, source_value, row_ctx, @generator)
      end
    end
  end
end
