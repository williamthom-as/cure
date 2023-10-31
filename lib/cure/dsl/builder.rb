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

      # @param [String,nil] column
      # @param [String] named_range
      # @param [Proc] block
      def candidate(column: nil, named_range: "_default", &block)
        candidate = Cure::Builder::Candidate.new(column, named_range)
        @candidates << candidate
        candidate.instance_exec(&block)
      end
    end
  end
end
