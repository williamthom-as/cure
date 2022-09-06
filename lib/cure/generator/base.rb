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
        translated = _generate(source_value)
        translated = "#{prefix}#{translated}" if prefix
        translated = "#{translated}#{suffix}" if suffix
        translated
      end

      private

      # @param [Object/Nil] _source_value
      # @return [String]
      def _generate(_source_value)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def prefix(default=nil)
        extract_property("prefix", default)
      end

      def suffix(default=nil)
        extract_property("suffix", default)
      end

      def length(default=nil)
        extract_property("length", default)
      end

      def property_name(default=nil)
        extract_property("name", default)
      end

      def extract_property(property, default_val)
        @options.fetch(property, default_val)
      end
    end

    class HexGenerator < Base
      private

      # @param [Object] _source_value
      def _generate(_source_value)
        1.upto(length(rand(0..9))).map { rand(0..15).to_s(16) }.join("")
      end
    end

    class NumberGenerator < Base
      private

      # @param [Object] _source_value
      def _generate(_source_value)
        1.upto(length(rand(0..9))).map { rand(1..9) }.join("").to_i
      end
    end

    class RedactGenerator < Base
      private

      # @param [Object] source_value
      def _generate(source_value)
        1.upto(length(source_value&.length || 5)).map { "X" }.join("")
      end
    end

    class PlaceholderGenerator < Base
      include Configuration

      private

      # @param [Object] _source_value
      def _generate(_source_value)
        value = config.placeholders[property_name]
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

    class FakerGenerator < Base
      private

      # @param [Object] _source_value
      def _generate(_source_value)
        mod_code = extract_property("module", nil)
        mod = Faker.const_get(mod_code)

        raise "No Faker module found for [#{mod_code}]" unless mod

        meth_code = extract_property("method", nil)&.to_sym
        raise "No Faker module found for [#{meth_code}]" unless mod.methods.include?(meth_code)

        mod.send(meth_code)
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
        (0...length(source_value&.length || 5)).map { arr[rand(arr.length)] }.join
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

    class CaseGenerator < Base

      private

      # @param [Object] source_value
      def _generate(source_value)
        result = case_options.fetch("switch").find { |opts| opts["case"] == source_value }&.fetch("return_value", nil)

        return result if result

        case_options.fetch("else", {}).fetch("return_value", nil)
      end

      # @return [Hash]
      def case_options
        @case_options ||= extract_property("statement", nil)
      end
    end
  end
end
