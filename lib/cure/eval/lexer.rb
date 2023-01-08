# frozen_string_literal: true

require "strscan"

module Cure
  module Eval
    class Lexer
      # @return [Array<Cure::Eval::Token>]
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

    # rubocop:disable Metrics/AbcSize
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

      # rubocop:disable Metrics/CyclomaticComplexity
      # @return [Cure::Eval::Token]
      def scan_next_token
        advance

        # Chars with an index lower or eq to SPACE are to be ignored
        while @peek.ord <= SPACE
          return nil if @peek == EOF

          advance
        end

        # If we find an identifier we scan thru until it isn't
        return scan_identifier if identifier_start? @peek

        return scan_number if number? @peek

        start = @scanner.pos

        case @peek.ord
        when PERIOD
          # We need to peek and see if the char following the current peek is a number,
          # if so, treat it as a decimal
          return number?(@scanner.peek(1)) ? scan_number : Token.new(start, ".")
        when L_PAREN, R_PAREN, L_BRACE, L_BRACKET, R_BRACKET, COMMA, COLON, SEMI_COLON
          return scan_character
        when SINGLE_QUOTE, DOUBLE_QUOTE
          return scan_string
        when SIMPLE_OPERATOR_SEARCH
          return scan_operator
        when GREATER_THAN, LESS_THAN, BANG, EQUALS
          return scan_complex_operator("=")
        when AMPERSAND
          return scan_complex_operator("&")
        when PIPE
          return scan_complex_operator("|")
        else
          print_current_peek
        end

        scan_next_token
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def advance
        if @scanner.eos?
          @peek = EOF
          return
        end

        @peek = @scanner.get_byte
      end

      private

      # @return [Cure::Eval::Token]
      def scan_identifier
        idx = @scanner.pos
        chars = []

        while identifier_start? @peek
          chars << @peek
          advance
        end

        Token.new(idx, chars.join)
      end

      # @return [Cure::Eval::Token]
      def scan_number
        idx = @scanner.pos
        nums = []

        is_integer = true

        loop do
          unless number?(@peek)
            if @peek.ord == PERIOD
              is_integer = false
            elsif sci_notation_start? @peek
              nums << @peek
              advance

              if sci_notation_sign? @peek
                nums << @peek
                advance
              end

              raise "Invalid scientific notation" unless number? @peek

              is_integer = false
            else
              break
            end
          end

          nums << @peek
          advance
        end

        number_str = nums.join
        Token.new(idx, is_integer ? Integer(number_str) : Float(number_str))
      end

      # @return [Cure::Eval::Token]
      def scan_character
        idx = @scanner.pos
        Token.new(idx, @peek)
      end

      # @return [Cure::Eval::Token]
      def scan_string
        idx = @scanner.pos
        chars = []

        quote = @peek.ord

        advance

        # while the quote hasn't closed
        while @peek.ord != quote
          raise "Unterminated quote" if @peek.ord == EOF

          chars << @peek
          advance
        end

        Token.new(idx, chars.join)
      end

      # @return [Cure::Eval::Token]
      def scan_operator
        idx = @scanner.pos
        Token.new(idx, @peek)
      end

      def scan_complex_operator(check_val)
        idx = @scanner.pos
        current = @peek

        if @scanner.peek(1) == check_val
          current << check_val
          advance
        end

        Token.new(idx, current)
      end

      # @param [String, Integer] char
      # @return [TrueClass, FalseClass]
      def identifier_start?(char)
        char_ord = char.ord
        (LOWER_A <= char_ord && char_ord <= LOWER_Z) ||
          (UPPER_A <= char_ord && char_ord <= UPPER_Z) ||
          (char_ord == UNDERSCORE) ||
          (char_ord == DOLLAR)
      end

      # @param [String, Integer] char
      # @return [TrueClass, FalseClass]
      def number?(char)
        char_ord = char.ord
        (NUM_ZERO <= char_ord && char_ord <= NUM_NINE)
      end

      # @param [String, Integer] char
      # @return [TrueClass, FalseClass]
      def sci_notation_start?(char)
        char_ord = char.ord
        [LOWER_E, UPPER_E].include?(char_ord)
      end

      # @param [String, Integer] char
      # @return [TrueClass, FalseClass]
      def sci_notation_sign?(char)
        char_ord = char.ord
        [MINUS, PLUS].include?(char_ord)
      end

      # @return [String (frozen)]
      def print_current_peek
        "#{@peek.ord} [#{@peek}]"
      end

      COMPLEX_OPERATORS = %w[= == != < > <= >= && || ! ? true false nil].freeze
      SIMPLE_OPERATORS = %w[+ - * / % ^].freeze

      COMPLEX_OPERATOR_SEARCH = ->(op) { COMPLEX_OPERATORS.map(&:ord).include?(op) }
      SIMPLE_OPERATOR_SEARCH = ->(op) { SIMPLE_OPERATORS.map(&:ord).include?(op) }

      EOF = -1
      SPACE = 32

      BANG = 33
      DOUBLE_QUOTE = 34
      DOLLAR = 36
      AMPERSAND = 38
      SINGLE_QUOTE = 39
      L_PAREN = 40
      R_PAREN = 41
      PLUS = 43
      COMMA = 44
      MINUS = 45
      PERIOD = 46

      NUM_ZERO = 48
      NUM_NINE = 57

      COLON = 58
      SEMI_COLON = 59
      LESS_THAN = 60
      EQUALS = 61
      GREATER_THAN = 62
      QUESTION_MARK = 63

      LOWER_A = 65
      LOWER_E = 101
      LOWER_Z = 122

      UPPER_A = 65
      UPPER_E = 69
      UPPER_Z = 90

      L_BRACKET = 91
      BACKSLASH = 92
      R_BRACKET = 93
      CARET = 94
      UNDERSCORE = 95

      L_BRACE = 123
      PIPE = 124
      R_BRACE = 125
      NBSP = 160
    end

    # rubocop:enable Metrics/AbcSize

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
