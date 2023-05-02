# frozen_string_literal: true

require "cure/helpers/object_helpers"
require "cure/validator/base_rule"
require "cure/log"

module Cure
  module Validator
    class Candidate
      include Helpers::ObjectHelpers
      include Log

      # Named range that column exists in
      # @return [String]
      attr_reader :named_range

      # Lookup column name for CSV.
      # @return [String]
      attr_reader :column

      # # What sort of data needs to be generated.
      # # @return [Array<Cure::Validator::BaseRule>]
      attr_reader :rules

      DEFAULT_OPTIONS = {
        fail_on_error: false
      }.freeze

      def initialize(column, named_range, options = {})
        @column = column
        @named_range = named_range || "_default"
        @options =  DEFAULT_OPTIONS.merge(options)
        @rules = []
      end

      def perform(value)
        result = @rules.filter_map do |rule|
          rule.process(value) ? nil : "#{rule.to_s} failed -> [#{@column}][#{value.to_s}]"
        end

        if @options[:fail_on_error] && result.size > 0
          raise "Validation failed:\n#{result.join("\n")}"
        end

        result
      end

      def with_rule(method_name, options={})
        klass_name = "Cure::Validator::#{method_name.to_s.split("_").map(&:capitalize).join}Rule"
        raise "#{method_name} is not valid" unless class_exists?(klass_name)

        @rules << Kernel.const_get(klass_name).new(@named_range, @column, options)
      end
    end
  end
end
