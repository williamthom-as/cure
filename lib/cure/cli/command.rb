# frozen_string_literal: true

require "cure"
require "cure/log"

module Cure
  module Cli
    class Command
      include Log

      # @param [String] command
      # @param [Array] argv
      def self.invoke(command, argv)
        extend Log

        handler = nil

        case command
        when "new"
          handler = NewCommand.new(argv)
        when "generate"
            handler = GenerateCommand.new(argv)
        when "run"
          handler = RunCommand.new(argv)
        else
          new.help
          return
        end

        handler.call
      rescue ArgumentError => aex
        handler ? handler.help(ex: aex) : new.help
      rescue StandardError => ex
        log_error(ex.message)
      end

      # @param [Array] argv
      def initialize(argv = [])
        @argv = argv
      end

      def call
        validate
        execute
      end

      def help(ex: nil)
        log_error ex.message if ex && ex.is_a?(StandardError)
        log_error "Error: unknown request"
        log_info "\nUsage: cure <command> [options]"
        log_info "\tRun:         cure run -t [template] -f [file]"
        log_info "\tNew Project: cure new [name]"
      end

      private

      # @return [void]
      def execute
        raise NotImplementedError
      end

      # @return [void]
      # @raise [ArgumentError, NotImplementedError]
      def validate
        raise NotImplementedError
      end
    end
  end
end
