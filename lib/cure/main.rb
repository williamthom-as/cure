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

    # @param [String] template_file_loc
    # @param [String] csv_file_loc
    # @param [String] output_dir
    # @return [Cure::Main]
    def self.init_from_file(template_file_loc, csv_file_loc, output_dir)
      # Run all init stuff here.
      # Run validator?

      main = Main.new
      template_hash = JSON.parse(main.read_file(template_file_loc))

      main.setup(template_hash, csv_file_loc, output_dir)
      main
    end

    # @param [Hash] template_hash
    # @param [String] csv_file_loc
    # @param [String] output_dir
    # @return [Cure::Main]
    def self.init_from_hash(template_hash, csv_file_loc, output_dir)
      # Run all init stuff here.
      # Run validator?

      main = Main.new
      main.setup(template_hash, csv_file_loc, output_dir)
      main
    end

    # @return [Cure::Transformation::Transform]
    attr_accessor :transformer

    # @return [Boolean]
    attr_reader :is_initialised

    def initialize
      @is_initialised = false
    end

    def run_export
      raise "Not init" unless @transformer

      ctx = build_ctx
      export(ctx)
    end

    # @return [Cure::Transform::TransformContext]
    def build_ctx
      @transformer.extract_from_file(config.source_file_location)
    end

    # @param [Hash] template
    # @param [String] csv_file_location
    # @param [String] output_dir
    # @return [Cure::Main]
    def setup(template, csv_file_location, output_dir)
      config = create_config(csv_file_location, template, output_dir)
      register_config(config)

      candidates = config.template["candidates"].map { |c| Cure::Transformation::Candidate.new.from_json(c) }

      @transformer = Cure::Transformation::Transform.new(candidates)
      @is_initialised = true

      self
    end

    private

    # @param [Cure::Transform::TransformContext] ctx
    def export(ctx)
      Cure::Export::Exporter.export_ctx(ctx, config.output_dir, "csv_file")
    end
  end
end
