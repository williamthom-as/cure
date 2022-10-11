# frozen_string_literal: true

require "cure/template/template"
require "cure/transformation/candidate"
require "cure/transformation/transform"
require "cure/export/exporter"
require "cure/coordinator"

require "cure"
require "json"

module Cure
  class Main
    include Configuration
    include Helpers::FileHelpers

    # @param [String] template_file_loc
    # @param [String] csv_file_loc
    # @param [String] output_dir
    # @return [Cure::Main]
    def self.init_from_file_locations(template_file_loc, csv_file_loc, output_dir)
      # Run all init stuff here.
      # Run validator?

      main = Main.new
      csv_file = main.open_file(csv_file_loc)
      template_hash = JSON.parse(main.read_file(template_file_loc))
      template = Template.from_hash(template_hash)
      main.setup(csv_file, template, output_dir)
      main
    end

    # @param [Hash] template_hash
    # @param [File] csv_file
    # @param [String] output_dir
    # @return [Cure::Main]
    def self.init(template_hash, csv_file, output_dir)
      # Run all init stuff here.
      # Run validator?

      main = Main.new
      template = Template.from_hash(template_hash)
      main.setup(csv_file, template, output_dir)
      main
    end

    # @return [Cure::Coordinator]
    attr_accessor :coordinator

    # @return [Boolean]
    attr_reader :is_initialised

    def initialize
      @is_initialised = false
      @coordinator = Coordinator.new
    end

    def run_export
      @coordinator.process
    end

    # @param [File] csv_file
    # @param [Cure::Template] template
    # @param [String] output_dir
    # @return [Cure::Main]
    def setup(csv_file, template, output_dir)
      config = create_config(csv_file, template, output_dir)
      register_config(config)

      self
    end
  end
end
