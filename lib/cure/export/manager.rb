# frozen_string_literal: true

module Cure
  module Export
    class Manager

      # @param [Array<Cure::Export::BaseProcessor>] candidates
      attr_reader :processors

      def initialize(named_range, processors)
        @named_range = named_range
        @processors = processors
      end

      def with_processors
        @processors.each(&:setup)

        yield @processors

        @processors.each(&:cleanup)
      end
    end
  end
end
