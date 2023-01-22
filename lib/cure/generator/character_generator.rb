# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class CharacterGenerator < BaseGenerator

      def initialize(options=nil)
        super(options)
      end

      private

      # @param [Object] source_value
      # @param [RowCtx] _row_ctx
      def _generate(source_value, _row_ctx)
        arr = build_options.map(&:to_a).flatten
        (0...length(source_value&.length || 5)).map { arr[rand(arr.length)] }.join
      end

      def build_options
        return [("a".."z"), ("A".."Z"), (0..9)] unless @options.key?(:types)

        type_array = @options[:types]

        arr = []
        arr << ("a".."z") if type_array.include? "lowercase"
        arr << ("A".."Z") if type_array.include? "uppercase"
        arr << (0..9) if type_array.include? "number"
        arr << ("!".."+") if type_array.include? "symbol"
        arr
      end

      def _describe
        "Will create a random list of #{@options["types"]} " \
        "with as many characters as the source string."
      end
    end
  end
end
