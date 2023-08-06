# frozen_string_literal: true

module Cure
  module Export
    class Manager

      # @param [Array<Cure::Validator::BaseRule>] candidates
      attr_reader :validators

      def initialize(named_range, validators)
        @named_range = named_range
        @validators = validators
      end

      # @param [Hash] row
      def process_row(row)

      end
    end
  end
end
