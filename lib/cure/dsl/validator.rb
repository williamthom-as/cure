# frozen_string_literal: true

require "cure/validator/candidate"

module Cure
  module Dsl
    class Validator

      attr_reader :candidates

      def initialize
        @candidates = []
      end

      def candidate(column: nil, named_range: "_default", options: {}, &block)
        candidate = Cure::Validator::Candidate.new(column, named_range, options)
        @candidates << candidate
        candidate.instance_exec(&block)
      end
    end
  end
end
