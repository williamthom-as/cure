# frozen_string_literal: true

require "cure/object_helpers"
require "cure/strategy/base"
require "cure/generator/base"
require "cure/log"

module Cure
  module Transformation
    # Per row, we will have a candidate for each transformation that needs to be made
    class Candidate
      include ObjectHelpers
      include Log

      # Lookup column name for CSV.
      # @return [String]
      attr_accessor :column

      # What sort of data needs to be generated.
      # @return [List<Translation>]
      attr_reader :translations

      attr_reader :no_match_translation

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

      def translations=(opts)
        @translations = opts.map { |o| Translation.new.from_hash(o) }
      end

      def no_match_translation=(opts)
        @no_match_translation = Translation.new.from_hash(opts)
      end
    end

    class Translation
      include ObjectHelpers

      # What sort of replacement is done, full/random/lookup/partial.
      # @return [Strategy::Base]
      attr_reader :strategy

      # What sort of data needs to be generated.
      # @return [Generator::Base]
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
        raise "Object fails validation" unless strategy.obj_is_valid?

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

