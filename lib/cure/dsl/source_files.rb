# frozen_string_literal: true

require "cure/builder/base_builder"
require "cure/builder/candidate"

module Cure
  module Dsl
    class SourceFiles

      attr_reader :candidates

      def initialize
        @candidates = []
      end

      def csv(type, value, ref_name: nil)
        candidate = SourceFile.new(type, value, ref_name)
        @candidates << candidate
      end

      def has_candidates?
        @candidates.length.positive?
      end

      class SourceFile
        attr_accessor :type, :value, :ref_name

        def initialize(type, value, ref_name)
          @type = type
          @value = value
          @ref_name = ref_name
        end
      end
    end
  end
end
