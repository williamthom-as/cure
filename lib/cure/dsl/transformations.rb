# frozen_string_literal: true

require "cure/generator/imports"
require "cure/strategy/imports"

require "cure/transformation/candidate"

module Cure
  module Dsl
    class Transformations
      attr_reader :candidates

      def initialize
        @candidates = []
      end

      def candidate(column:, named_range:, &block)
        candidate = Cure::Transformation::Candidate.new(column, named_range: named_range)
        @candidates << candidate
        candidate.instance_exec(&block)
      end

      def placeholders(hash)
        @placeholders = hash
      end
    end
  end
end

