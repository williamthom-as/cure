# frozen_string_literal: true

require "cure/generator/base_generator"
require "digest"

module Cure
  module Generator
    class DeterministicScrambleGenerator < BaseGenerator
      private

      # @param [Object] source_value
      # @param [RowCtx] row_ctx
      def _generate(source_value, row_ctx)
        return source_value unless @options&.key?(:key) && @options&.key?(:magnitude)

        randomiser = DeterministicNumberRandomiser.new(
          key: @options[:key],
          magnitude: @options[:magnitude]
        )

        randomiser.call(source_value, row_ctx)
      end

      def _describe
        "Will deterministically randomise a number."
      end
    end

    class DeterministicNumberRandomiser

      def initialize(key:, magnitude:)
        @key = key.to_s
        @seed = Digest::SHA256.hexdigest(@key).to_i(16)
        @magnitude = magnitude
      end

      def call(source, _row_ctx)
        return source if source.nil? || source.empty?

        value = source.to_f

        return unless numeric?(value)

        digest = Digest::SHA256.hexdigest(@key + source.to_s)
        prng = Random.new(@seed + digest.to_i(16))

        jitter_amount = case @magnitude
          when :tenths then prng.rand(0.1..0.9).round(1)
          when :ones then (prng.rand(1..9)).round
          when :tens then (prng.rand(10..60) / 10).round * 10
          when :hundredths then prng.rand(0.01..0.99).round(2)
          when :thousandths then prng.rand(0.001..0.999).round(3)
          when :ten_thousandths then prng.rand(0.0001..0.9999).round(4)
          when :hundred_thousandths then prng.rand(0.00001..0.99999).round(5)
          when :millionths then prng.rand(0.000001..0.999999).round(6)
          else
            raise ArgumentError,
              "Invalid magnitude: #{@magnitude}. Must be one of :tens, :ones, :tenths, :hundredths, :thousandths," \
                ":ten_thousandths, :hundred_thousandths, :millionths."
        end

        result = if prng.rand(2) == 0
          value + jitter_amount
        else
          value - jitter_amount
        end

        if source.include?(".")
          result.round(2).to_s
        else
          result.to_i.to_s
        end
      rescue
        # If we can't parse the source value as a number,
        # we generally return as is
        source
      end

      private

      def numeric?(source)
        Float(source) rescue false
      end

    end
  end
end
