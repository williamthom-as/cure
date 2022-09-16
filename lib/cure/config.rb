# frozen_string_literal: true

require "cure"
require "json"
require "singleton"

module Cure
  module Configuration
    # @return [Config]
    def config
      conf = ConfigurationSource.instance.config
      raise "Set config first" unless conf

      conf
    end

    # @param [Config] request_config
    def register_config(request_config)
      ConfigurationSource.instance.load_config(request_config)
    end

    # @param [String] source_file_location
    # @param [Cure::Template] template
    # @param [String] output_dir
    # @return [Config]
    def create_config(source_file_location, template, output_dir)
      Config.new(source_file_location, template, output_dir)
    end

    class Config
      attr_accessor :source_file_location, :template, :output_dir

      # @param [String] source_file_location
      # @param [Cure::Template] template
      # @param [String] output_dir
      def initialize(source_file_location, template, output_dir)
        @source_file_location = source_file_location
        @template = template
        @output_dir = output_dir
      end

      def placeholders
        @template.transformations.placeholders || {}
      end
    end

    class ConfigurationSource
      include Singleton

      attr_reader :config

      # @param [Config] config
      # @return [Config]
      def load_config(config)
        @config = config
      end
    end
  end
end
