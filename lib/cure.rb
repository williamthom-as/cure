# frozen_string_literal: true

require "cure/version"
require "cure/log"
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


  end
end
