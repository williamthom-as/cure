# frozen_string_literal: true

require "cure/log"
require "cure/launcher"
require "cure/config"
require "cure/version"
require "cure/helpers/file_helpers"

require "cure/dsl/template"
require "cure/transformation/transform"

require "logger"

module Cure
  class << self
    attr_writer :logger

    attr_reader :config

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
        log.formatter = proc do |severity, _datetime, _progname, msg|
          "[#{severity}] #{msg}\n"
        end
      end
    end

    def init(&block)
      launcher = Cure::Launcher.new
      launcher.with_config(&block)
    end

    def init_from_file(file_path)
      launcher = Cure::Launcher.new
      launcher.with_config_file(file_path)
    end
  end
end
