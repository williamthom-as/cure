# frozen_string_literal: true

require "cure/generator/imports"
require "cure/strategy/imports"

require "cure/transformation/candidate"

module Cure
  module Dsl
    class Transformations

      attr_reader :candidates, :placeholders

      def initialize
        @candidates = []
        @placeholders = []
      end

      def candidate(column:, named_range: "_default", options: {}, &block)
        candidate = Candidate.new(column, named_range: named_range)
        candidate.instance_exec(&block)

        @candidates << Transformation::Candidate
                       .new(candidate.column, named_range: candidate.named_range, options: options)
                       .with_translations(candidate.translations)
                       .with_no_match_translation(candidate.no_match_translation)
      end

      def place_holders(hash)
        @placeholders = hash
      end

      class Candidate

        attr_reader :column, :named_range, :translations, :no_match_translation

        def initialize(column, named_range:)
          @column = column
          @named_range = named_range

          @translations = []
          @no_match_translation = nil
        end

        def with_translation(&block)
          translation = Translation.new
          translation.instance_exec(&block)

          @translations << Transformation::Translation.new(translation.strategy, translation.generator)
        end

        def if_no_match(&block)
          no_match_translation = Translation.new
          no_match_translation.instance_exec(&block)

          @no_match_translation = Transformation::Translation.new(
            no_match_translation.strategy,
            no_match_translation.generator
          )
        end
      end

      class Translation

        attr_reader :strategy, :generator

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
end
