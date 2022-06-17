# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/version"

require "cure/file_helpers"
require "cure/transformation/transform"

require "cure/main"

require "logger"

module Cure
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end


  end
end
