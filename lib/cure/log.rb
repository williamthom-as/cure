# frozen_string_literal: true

require "cure"

module Cure
  module Log
    # @param [String] _message
    def log_trace(_message)
      # Ruby default logger doesnt have trace, so my version
      # is to just uncomment it when you need it for now.
      # Cure.logger.trace(message)
    end

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
    # @param [Exception/Nil] exception
    def log_error(message, exception=nil)
      Cure.logger.error(message)
      Cure.logger.error(exception.backtrace.join("\n")) unless exception.nil?
    end
  end
end
