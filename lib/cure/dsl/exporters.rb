# frozen_string_literal: true

require "cure/export/base_processor"
require "cure/extract/named_range"

module Cure
  module Dsl
    class Exporters

      attr_reader :processors

      def initialize
        @processors = []
      end

      def respond_to_missing?(_method_name, _include_private=false)
        true
      end

      def method_missing(method_name, **args)
        klass_name = "Cure::Export::#{method_name.to_s.capitalize}Processor"
        raise "#{method_name} is not valid" unless class_exists?(klass_name)

        @processors << Kernel.const_get(klass_name).new(
          args[:named_range] || Cure::Extract::NamedRange.default_named_range,
          args || {}
        )
      end

      def class_exists?(klass_name)
        klass = Module.const_get(klass_name)
        klass.is_a?(Class)
      rescue NameError
        false
      end
    end
  end
end
