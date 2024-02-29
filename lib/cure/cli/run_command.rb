# frozen_string_literal: true

require "cure/cli/command"

module Cure
  module Cli
    class RunCommand < Command
      def initialize(args)
        super(args)
      end

      private

      def execute
        log_info "Not implemented yet!"
      end
    end
  end
end
