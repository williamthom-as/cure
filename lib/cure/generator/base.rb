# frozen_string_literal: true

module Cure
  module Generator
    class Base

      # @return [Hash]
      attr_accessor :options

      def initialize(options)
        @options = options
      end

      def generate
        _generate
      end

      private

      def _generate
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class HexGenerator < Base

      private

      def _generate
        1.upto(@options["length"] || rand(0..9)).map { rand(0..15).to_s(16) }.join("")
      end

    end

    class NumberGenerator < Base

      private

      def _generate
        1.upto(@options["length"] || rand(0..9)).map { rand(1..9) }.join("").to_i
      end

    end

    class RedactGenerator < Base

      private

      def _generate
        "XXXXX"
      end

    end

    # TODO
    class CharacterGenerator < Base

      private

      def _generate
        # 1.upto(@options["length"] || rand(0..9)).map { rand(1..9) }.join("").to_i
      end

    end

    class PlaceholderGenerator < Base

      private

      def _generate(opts={})
        0.upto(opts[:length] || rand(0..9)).map { rand(1..10) }.join("").to_i
      end

    end

    require "securerandom"

    class GuidGenerator < Base

      private

      def _generate
        SecureRandom.uuid.to_s
      end

    end

    require "faker"

    # TODO
    class FakerGenerator < Base

      private

      def _generate(_opts={})
        # faker code
      end

    end

  end
end
