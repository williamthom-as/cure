# frozen_string_literal: true

require "cure/builder/base_builder"
require "cure/builder/candidate"

module Cure
  module Dsl
    class Builder

      attr_reader :candidates

      def initialize
        @candidates = []
      end

      def candidate(column:, named_range:, &block)
        candidate = Cure::Builder::Candidate.new(column, named_range)
        @candidates << candidate
        candidate.instance_exec(&block)
      end
    end
  end
end
