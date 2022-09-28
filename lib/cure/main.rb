# frozen_string_literal: true

require "cure/template/template"
require "cure/transformation/candidate"
require "cure/transformation/transform"
require "cure/export/exporter"

require "cure"
require "json"

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
      template = Template.from_hash(template_hash)
      main.setup(csv_file_loc, template, output_dir)
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
      template = Template.from_hash(template_hash)
      main.setup(csv_file_loc, template, output_dir)
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

      result = run_transform
      dispatch(result)
    end

    # @return [Hash]
    def run_transform
      @transformer.extract_from_file(config.source_file_location)
    end

    # @param [String] csv_file_location
    # @param [Cure::Template] template
    # @param [String] output_dir
    # @return [Cure::Main]
    def setup(csv_file_location, template, output_dir)
      config = create_config(csv_file_location, template, output_dir)
      register_config(config)

      # This is unnecessary, leave for now but fix later until we move Template to builder.
      @transformer = Cure::Transformation::Transform.new(config.template.transformations.candidates)
      @is_initialised = true

      self
    end

    private

    # @param [Hash] result
    def dispatch(result)
      Cure::Export::Exporter.export_result(result, config.output_dir )
    end
  end
end
