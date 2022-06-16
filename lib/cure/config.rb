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

    class Config
      attr_accessor :source_file, :template_file, :output_dir
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
