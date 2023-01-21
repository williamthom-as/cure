# frozen_string_literal: true

require "cure/dsl/extraction"
require "cure/dsl/builder"
require "cure/dsl/transformations"
require "cure/dsl/exporters"

module Cure
  module Dsl
    class DslHandler

      def self.init(&block)
        Dsl::DslHandler.new(block)
      end

      def self.init_from_content(dsl_source, identifier, line_number=1)
        proc = Binding.get.eval(<<-SOURCE, identifier, line_number)
          Proc.new do
            #{dsl_source}
          end
        SOURCE

        Dsl::DslHandler.new(proc)
      end

      def initialize(proc)
        @proc = proc
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

      def initialize
        @extraction = Extraction.new
        @builder = Builder.new
        @transformations = Transformations.new
        @exporters = Exporters.new
      end

      def extract(&block)
        @extraction.instance_exec(&block)
      end

      def build(&block)
        @builder.instance_exec(&block)
      end

      def transform(&block)
        @transformations.instance_exec(&block)
      end

      def export(&block)
        @exporters.instance_exec(&block)
      end
    end
  end
end

