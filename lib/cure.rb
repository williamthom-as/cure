# frozen_string_literal: true

require "cure/log"
require "cure/main"
require "cure/config"
require "cure/version"
require "cure/helpers/file_helpers"

require "cure/template/template"
require "cure/transformation/transform"

require "logger"

module Cure
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end

    # @param [String] csv_file_location
    # @param [Hash] template
    # @return [File] output_file
    def process(template, csv_file_location, output_dir)
      # Main.init_from_hash(template, csv_file_location, output_dir)
    end
  end
end
