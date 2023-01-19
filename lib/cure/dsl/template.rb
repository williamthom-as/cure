# frozen_string_literal: true

module Cure
  module Dsl
    class DslHandler
      def initialize(dsl_source, identifier, line_number=1)
        @proc = Binding.get.eval(<<-SOURCE, identifier, line_number)
          Proc.new do
            #{dsl_source}
          end
        SOURCE
      end

      def generate(instance_variables={})
        dsl = Cure::Dsl::Template.new
        instance_variables.each do |name, value|
          dsl.instance_variable_set("@#{name}", value)
        end

        dsl.instance_eval(&@proc)

        dsl
      end
    end

    module Binding
      # @return [Object] Empty object for binding purposes
      def self.get
        binding
      end
    end

    class Template

      # @return [Dsl::Extraction]
      attr_reader :extraction

      # @return [Dsl::Builder]
      attr_reader :builder

      # @return [Dsl::Transformations]
      attr_reader :transformations

      # @return [Dsl::Exporters]
      attr_reader :exporters

      def csv(properties={})
        puts properties
      end

      def extract(&block)
        @extraction = Extraction.new
        @extraction.instance_exec(&block)
      end

      def build(&block)
        @builder = Builder.new
        @builder.instance_exec(&block)
      end

      def transform(&block)
        @transformations = Transformations.new
        @transformations.instance_exec(&block)
      end

      def export(&block)
        @exporters = Exporters.new
        @exporters.instance_exec(&block)
      end
    end

    class Extraction

      attr_reader :named_ranges, :variables

      def initialize
        @named_ranges = []
        @variables = []
      end

      def named_range(name:, at:, headers: nil)
        @named_ranges << NamedRange.new(name, at, headers)
      end

      def variable(name:, at:)
        @variables << Variable.new(name, at)
      end

      class NamedRange

        attr_accessor :name, :at, :headers

        def initialize(name, at, headers)
          @name = name
          @at = at
          @headers = headers
        end

      end

      class Variable

        attr_accessor :name, :at

        def initialize(name, at)
          @name = name
          @at = at
        end

      end
    end

    require "cure/builder/base_builder"

    class Builder

      attr_reader :candidates

      def initialize
        @candidates = []
      end

      def candidate(column:, named_range:, &block)
        candidate = Candidate.new(column, named_range)
        @candidates << candidate
        candidate.instance_exec(&block)
      end

      class Candidate

        attr_reader :column, :named_range, :action

        def initialize(column, named_range)
          @column = column
          @named_range = named_range
        end

        def respond_to_missing?(_method_name, _include_private=false)
          true
        end

        def method_missing(method_name, args)
          klass_name = "Cure::Builder::#{method_name.to_s.capitalize}Builder"
          raise "#{method_name} is not valid" unless class_exists?(klass_name)

          @action = Kernel.const_get(klass_name).new(@named_range, @column, args[:options] || {})
        end

        def class_exists?(klass_name)
          klass = Module.const_get(klass_name)
          klass.is_a?(Class)
        rescue NameError
          false
        end
      end
    end

    require "cure/generator/imports"
    require "cure/strategy/imports"

    class Transformations
      attr_reader :candidates

      def initialize
        @candidates = []
      end

      def candidate(column:, named_range:, &block)
        candidate = Candidate.new(column, named_range)
        @candidates << candidate
        candidate.instance_exec(&block)
      end

      def placeholders(hash)
        @placeholders = hash
      end

      class Candidate

        def initialize(column, named_range)
          @column = column
          @named_range = named_range

          @transforms = []
          @no_match_translation = nil
        end

        def translation(&block)
          translation = Translation.new
          @transforms << translation
          translation.instance_exec(&block)
        end

        def no_match_translation(&block)
          no_match_translation = Translation.new
          @no_match_translation = no_match_translation
          no_match_translation.instance_exec(&block)
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

    require "cure/export/base_processor"

    class Exporters

    end
  end
end

