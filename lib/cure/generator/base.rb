# frozen_string_literal: true

module Cure
  module Generator
    class Base

      # @return [Hash]
      attr_accessor :options

      def initialize(options={})
        @options = options
      end

      # @param [Object/Nil] source_value
      # @return [String]
      def generate(source_value=nil)
        _generate(source_value)
      end

      private

      # @param [Object/Nil] _source_value
      # @return [String]
      def _generate(_source_value)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class HexGenerator < Base

      private

      # @param [Object] _source_value
      def _generate(_source_value)
        1.upto(@options["length"] || rand(0..9)).map { rand(0..15).to_s(16) }.join("")
      end

    end

    class NumberGenerator < Base

      private

      # @param [Object] _source_value
      def _generate(_source_value)
        1.upto(@options["length"] || rand(0..9)).map { rand(1..9) }.join("").to_i
      end

    end

    class RedactGenerator < Base

      private

      # @param [Object] source_value
      def _generate(source_value)
        1.upto(source_value&.length || 5).map { "X" }.join("")
      end

    end

    class PlaceholderGenerator < Base
      include Configuration

      private

      # @param [Object] _source_value
      def _generate(_source_value)
        value = config.placeholders[@options["name"]]
        value || raise("Missing placeholder value. Available candidates: [#{config.placeholders.join(", ")}]")
      end

    end

    require "securerandom"

    class GuidGenerator < Base

      private

      # @param [Object] _source_value
      def _generate(_source_value)
        SecureRandom.uuid.to_s
      end

    end

    require "faker"

    # TODO
    class FakerGenerator < Base

      private

      # @param [Object] _source_value
      def _generate(_source_value)
        # faker code
      end

    end

    class CharacterGenerator < Base

      def initialize(options=nil)
        super(options)
      end

      private

      # @param [Object] source_value
      def _generate(source_value)
        arr = build_options.map(&:to_a).flatten
        (0...@options["length"] || source_value&.length || 5).map { arr[rand(arr.length)] }.join
      end

      def build_options
        return [("a".."z"), ("A".."Z"), (0..9)] unless @options.key?("types")

        type_array = @options["types"]

        arr = []
        arr << ("a".."z") if type_array.include? "lowercase"
        arr << ("A".."Z") if type_array.include? "uppercase"
        arr << (0..9) if type_array.include? "number"
        arr << ("!".."+") if type_array.include? "symbol"
        arr
      end
    end
  end
end
