# frozen_string_literal: true

require "cure/log"
require "cure/dsl/extraction"
require "cure/dsl/builder"
require "cure/dsl/validator"
require "cure/dsl/transformations"
require "cure/dsl/exporters"
require "cure/dsl/queries"
require "cure/dsl/metadata"
require "cure/dsl/source_files"
require "cure/dsl/database_config"

module Cure
  module Dsl
    class DslHandler
      include Log
      def self.init(&block)
        DslHandler.new(block)
      end

      def self.init_from_content(dsl_source, identifier, line_number=1)
        proc = Binding.get.eval(<<-SOURCE, identifier, line_number)
          Proc.new do
            #{dsl_source}
          end
        SOURCE

        DslHandler.new(proc)
      end

      def initialize(proc)
        @proc = proc
      end

      def generate(instance_variables={})
        dsl = Template.new
        instance_variables.each do |name, value|
          dsl.instance_variable_set("@#{name}", value)
        end

        dsl.instance_eval(&@proc)
        dsl

      rescue StandardError => e
        log_error "Error parsing DSL: #{e.message}"

        # Raise specific error in future.
        raise e
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

      # @return [Dsl::Validator]
      attr_reader :validator

      # @return [Dsl::Transformations]
      attr_reader :transformations

      # @return [Dsl::Exporters]
      attr_reader :exporters

      # @return [Dsl::Queries]
      attr_reader :queries

      # @return [Dsl::Metadata]
      attr_reader :meta_data

      # @return [Dsl::SourceFiles]
      attr_reader :source_files

      # @return [Dsl::DatabaseConfig]
      attr_reader :database_config

      def initialize
        @source_files = SourceFiles.new
        @extraction = Extraction.new
        @builder = Builder.new
        @validator = Validator.new
        @transformations = Transformations.new
        @exporters = Exporters.new
        @queries = Queries.new
        @meta_data = Metadata.new
        @database_config = DatabaseConfig.new
      end

      private

      def database(&block)
        @database_config.instance_exec(&block)
      end

      def sources(&block)
        @source_files.instance_exec(&block)
      end

      def extract(&block)
        @extraction.instance_exec(&block)
      end

      def query(&block)
        @queries.instance_exec(&block)
      end

      def build(&block)
        @builder.instance_exec(&block)
      end

      def validate(&block)
        @validator.instance_exec(&block)
      end

      def transform(&block)
        @transformations.instance_exec(&block)
      end

      def metadata(&block)
        @meta_data.instance_exec(&block)
      end

      def export(&block)
        @exporters.instance_exec(&block)
      end
    end
  end
end
