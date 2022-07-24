# frozen_string_literal: true

require "cure"
require "json"
require "cure/transformation/candidate"
require "cure/transformation/transform"
require "cure/export/exporter"

module Cure

  class Main
    include Configuration
    include FileHelpers

    # @return [Cure::Main]
    def self.init(template_file, csv_file, output_dir)
      # Run all init stuff here.
      main = Main.new
      main.setup(template_file, csv_file, output_dir)

      main
    end

    # @return [Cure::Transformation::Transform]
    attr_accessor :transformer

    # @return [Boolean]
    attr_reader :is_initialised

    def initialize
      @is_initialised = false
    end

    def run
      raise "Not init" unless @transformer

      ctx = build_ctx
      export(ctx)
    end

    # @return [Cure::Transform::TransformContext]
    def build_ctx
      @transformer.extract_from_file(config.source_file_location)
    end

    def setup(template_file, csv_file, output_dir)
      config = create_config(csv_file, JSON.parse(read_file(template_file)), output_dir)
      register_config(config)

      candidates = config.template["candidates"].map { |c| Cure::Transformation::Candidate.new.from_json(c) }

      @transformer = Cure::Transformation::Transform.new(candidates)
      @is_initialised = true
    end

    private

    # @param [Cure::Transform::TransformContext] ctx
    def export(ctx)
      Cure::Export::Exporter.export_ctx(ctx, config.output_dir, "csv_file")
    end
  end
end
