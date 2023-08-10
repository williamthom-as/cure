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

    def initialize(coordinator: Coordinator.new, planner: Planner.new)
      @coordinator = coordinator
      @planner = planner
      @validated = false
      @csv_files = []
    end

    # This will only support single file CSV processing, and is deprecated now
    #
    # @param [Symbol] type
    # @param [Object] obj
    # @param [TrueClass,FalseClass] print_query_plan
    # @return [void]
    # @deprecated
    def process(type, obj, print_query_plan: true)
      @csv_files << Cure::Configuration::CsvFileProxy.load_file(type, obj, "_default")
      run_export(print_query_plan: print_query_plan)
    end

    def run_export(print_query_plan: true)
      setup

      raise "Not initialized" unless @validated

      query_plan if print_query_plan
      @coordinator.process
    end

    # -- Builder opts start

    # @param [Symbol] type
    # @param [Object] obj
    # @return [Cure::Main]
    def with_csv_file(type, obj, ref_name: nil)
      if ref_name.nil?
        ref_name = @csv_files.length.zero? ? "_default" : "_default_#{@csv_files.length}"
      end

      @csv_files << Cure::Configuration::CsvFileProxy.load_file(type, obj, ref_name)
      self
    end

    # @return [Cure::Main]
    def with_config(&block)
      raise "No block given to config" unless block

      dsl = Dsl::DslHandler.init(&block)
      @template = dsl.generate

      load_csv_from_config

      self
    end

    # @return [Cure::Main]
    def with_config_file(file_location)
      contents = read_file(file_location.to_s)

      dsl = Dsl::DslHandler.init_from_content(contents, "cure")
      @template = dsl.generate

      load_csv_from_config

      self
    end

    # -- Builder end

    # @return [Cure::Main]
    def setup
      raise "CSV File(s) are required" if @csv_files.empty?
      raise "Template is required" unless @template

      config = create_config(@csv_files, @template)
      register_config(config)

      init_database

      @validated = true
      self
    end

    # @return [void]
    def query_plan
      raise "Not initialized" unless @validated

      @planner.process
    end

    private

    def load_csv_from_config
      return unless @template.source_files.has_candidates?

      @template.source_files.candidates.each do |source|
        with_csv_file(source.type, source.value, ref_name: source.ref_name)
      end
    end
  end
end
