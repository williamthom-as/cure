# frozen_string_literal: true

require "cure/transformation/candidate"
require "cure/transformation/transform"
require "cure/coordinator"
require "cure/database"
require "cure/planner"
require "cure/config"

require "json"
require "yaml"

module Cure
  class Launcher
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

    # @return [Cure::Main]
    def setup
      raise "CSV File is required" unless @csv_file
      raise "Template is required" unless @template

      config = create_config(@csv_file, @template)
      register_config(config)

      init_database

      @validated = true
      self
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

    # @param [Symbol] type
    # @param [Object] obj
    def with_csv_file(type, obj)
      @csv_file = Cure::Configuration::CsvFileProxy.load_file(type, obj)
      self
    end

    def with_config(&block)
      raise "No block given to config" unless block

      dsl = Dsl::DslHandler.init(&block)
      @template = dsl.generate

      self
    end

    def with_config_file(file_location)
      contents = read_file(file_location.to_s)

      dsl = Dsl::DslHandler.init_from_content(contents, "cure")
      @template = dsl.generate
      self
    end
  end
end
