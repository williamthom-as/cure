# frozen_string_literal: true

require "cure/helpers/object_helpers"
require "cure/strategy/imports"
require "cure/generator/imports"
require "cure/log"

module Cure
  module Transformation
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
      # @return [List<Translation>]
      attr_reader :translations

      # @return [Translation]
      attr_reader :no_match_translation

      def initialize
        @translations = []
        @named_range = "default"
      end

      # @param [String] source_value
      # @return [String]
      # Transforms the existing value
      def perform(source_value)
        # log_debug("Performing substitution for [#{@column}] with [#{@translations.length}] translations")
        value = source_value

        @translations.each do |translation|
          temp = translation.extract(value)
          value = temp if temp
        end

        if value == source_value
          log_debug("No translation made for #{value} [#{source_value}]")
          value = @no_match_translation&.extract(source_value)
          log_debug("Translated to #{value} from [#{source_value}]")
        end

        value
      end

      # @param [Hash] opts
      def translations=(opts)
        @translations = opts.map { |o| Translation.new.from_hash(o) }
      end

      # @param [Hash] opts
      def no_match_translation=(opts)
        @no_match_translation = Translation.new.from_hash(opts)
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
      def extract(source_value)
        @strategy.extract(source_value, @generator)
      end

      # @param [Hash] opts
      def strategy=(opts)
        clazz_name = "Cure::Strategy::#{opts["name"].to_s.capitalize}Strategy"
        strategy = Kernel.const_get(clazz_name).new(opts["options"] || {})

        @strategy = strategy
      end

      # @param [Hash] opts
      def generator=(opts)
        clazz_name = "Cure::Generator::#{opts["name"].to_s.capitalize}Generator"
        @generator = Kernel.const_get(clazz_name).new(opts["options"] || {})
      end

    end
  end
end
