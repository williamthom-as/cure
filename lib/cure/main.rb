# frozen_string_literal: true

require "cure/template/template"
require "cure/transformation/candidate"
require "cure/transformation/transform"
require "cure/coordinator"
require "cure/database"
require "cure/planner"
require "cure/config"

require "json"
require "yaml"

module Cure
  class Main
    include Database
    include Configuration
    include Helpers::FileHelpers

    # @return [Cure::Coordinator]
    attr_accessor :coordinator

    def initialize
      @coordinator = Coordinator.new
      @planner = Planner.new
      @validated = false
    end

    def run_export(print_query_plan: true)
      raise "Not initialized" unless @validated

      query_plan if print_query_plan
      @coordinator.process
    end

    def query_plan
      raise "Not initialized" unless @validated

      @planner.process
    end

    # @return [Cure::Main]
    def init
      raise "CSV File is not initialized" unless @csv_file
      raise "Template is not initialized" unless @template

      config = create_config(@csv_file, @template)
      register_config(config)

      init_database

      @validated = true
      self
    end

    # @param [Symbol] type
    # @param [Object] template_file
    #
    # TODO: Do a better interface in the future
    def with_template(type, template_file) # rubocop:disable Metrics/AbcSize
      if type == :template && template_file.is_a?(Hash)
        @template = Template.from_hash(template_file)
        return self
      end

      ext = File.extname(template_file.to_s).tr(".", "")
      if ext.downcase == "json"
        contents = JSON.parse(read_file(template_file.to_s))
        @template = Template.from_hash(contents)
        return self
      end

      if %w[yaml yml].include?(ext.downcase)
        contents = YAML.load_file(template_file.to_s)
        @template = Template.from_hash(contents)
        return self
      end

      raise "No template parsing capability for #{ext} files"
    end

    # @param [Symbol] type
    # @param [Object] obj
    def with_csv_file(type, obj)
      @csv_file = Cure::Configuration::CsvFileProxy.load_file(type, obj)
      self
    end
  end
end

# Desired API
# m = Main.new
# m.load_csv_file(:file, file)
# m.load_template(:file, template_file)
# m.init
# m.run_export
