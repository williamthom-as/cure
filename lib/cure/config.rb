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

    # @param [File] source_file
    # @param [Cure::Template] template
    # @param [String] output_dir
    # @return [Config]
    def create_config(source_file, template, output_dir)
      Config.new(source_file, template, output_dir)
    end

    # If we are overloading here as a "data store" and "config store", we
    # could break out variables and placeholders into their own singleton.
    #
    # This should be a kind of instance cache, which loads once per run,
    # and junk can be jammed in there?
    class Config
      attr_accessor :source_file, :output_dir

      # @return [Cure::Template] template
      attr_accessor :template

      # @return [Hash] variables
      attr_accessor :variables

      # @param [File] source_file
      # @param [Cure::Template] template
      # @param [String] output_dir
      def initialize(source_file, template, output_dir)
        @source_file = source_file
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
