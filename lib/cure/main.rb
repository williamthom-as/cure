# frozen_string_literal: true

require "cure/template/template"
require "cure/transformation/candidate"
require "cure/transformation/transform"
require "cure/coordinator"
require "cure/planner"

require "json"
require "yaml"

module Cure
  class Main
    include Configuration
    include Helpers::FileHelpers

    # @param [String] template_file_loc
    # @param [String] csv_file_loc
    # @return [Cure::Main]
    def self.init_from_file_locations(template_file_loc, csv_file_loc)
      # Run all init stuff here.
      # Run validator?

      main = Main.new
      csv_file = main.open_file(csv_file_loc)
      template_hash = main.load_template(template_file_loc)
      template = Template.from_hash(template_hash)
      main.setup(csv_file, template)
      main
    end

    # @param [Hash] template_hash
    # @param [File] csv_file
    # @return [Cure::Main]
    def self.init(template_hash, csv_file)
      # Run all init stuff here.
      # Run validator?

      main = Main.new
      template = Template.from_hash(template_hash)
      main.setup(csv_file, template)
      main
    end

    # @return [Cure::Coordinator]
    attr_accessor :coordinator

    # @return [Boolean]
    attr_reader :is_initialised

    def initialize
      @is_initialised = false
      @coordinator = Coordinator.new
      @planner = Planner.new
    end

    def run_export
      query_plan
      @coordinator.process
    end

    def query_plan
      @planner.process
    end

    # @param [File] csv_file
    # @param [Cure::Template] template
    # @return [Cure::Main]
    def setup(csv_file, template)
      config = create_config(csv_file, template)
      register_config(config)

      self
    end

    def load_template(template_file_loc)
      ext = File.extname(template_file_loc).tr(".", "")
      return JSON.parse(read_file(template_file_loc)) if ext.downcase == "json"
      return YAML.load_file(template_file_loc) if %w[yaml yml].include?(ext.downcase)

      raise "No template parsing capability for #{ext} files"
    end
  end
end
