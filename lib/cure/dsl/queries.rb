# frozen_string_literal: true

require "cure/builder/base_builder"
require "cure/builder/candidate"

module Cure
  module Dsl
    class Queries

      attr_reader :candidates

      def initialize
        @candidates = []
      end

      def with(query:, named_range: "_default")
        candidate = Query.new(named_range.to_sym, query)
        @candidates << candidate
      end

      def find(named_range)
        @candidates.find { |candidate| candidate.named_range.to_sym == named_range.to_sym }
      end

      class Query
        attr_reader :named_range, :query

        def initialize(named_range, query)
          @named_range = named_range
          @query = query
        end
      end

    end
  end
end
