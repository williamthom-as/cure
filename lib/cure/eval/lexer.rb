# frozen_string_literal: true

require "strscan"

module Cure
  module Eval
    class Lexer
      def self.lex(text, opts={})
        scanner = Scanner.new(text, opts)
        tokens = []

        current_token = scanner.scan_next_token
        while current_token
          tokens << current_token
          current_token = scanner.scan_next_token
        end

        tokens
      end
    end

    class Scanner

      attr_reader :input, :length, :peek, :opts

      # @param [String] input
      # @param [Hash] opts
      def initialize(input, opts={})
        @scanner = StringScanner.new(input)
        @length = input.length
        @peek = 0

        @opts = opts
      end

      def scan_next_token
        advance

        # Chars with an index lower or eq to SPACE are to be ignored
        while @peek.ord <= SPACE
          return nil if @peek == EOF

          advance
        end

        @peek
      end

      def advance
        if @scanner.eos?
          @peek = EOF
          return
        end

        @peek = @scanner.get_byte
      end

      private

      def print_current_peek
        "#{@peek.ord} [#{@peek}]"
      end

      EOF = -1
      SPACE = 32

    end

    class Token

      attr_reader :index, :text

      def initialize(index, text)
        @index = index
        @text = text
      end

      def to_s
        "Token(#{text})"
      end
    end

  end
end
