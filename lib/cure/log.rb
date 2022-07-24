# frozen_string_literal: true

require "cure"

module Cure
  module Log
    # @param [String] message
    def log_debug(message)
      Cure.logger.debug(message)
    end

    # @param [String] message
    def log_info(message)
      Cure.logger.info(message)
    end

    # @param [String] message
    def log_warn(message)
      Cure.logger.warn(message)
    end

    # @param [String] message
    # @param [Exception/Nil] ex
    def log_error(message, ex=nil)
      Cure.logger.error(message)
      Cure.logger.error(ex.backtrace.join("\n")) unless ex.nil?
    end
  end
end
