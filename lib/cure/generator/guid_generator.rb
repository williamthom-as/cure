# frozen_string_literal: true

require "cure/generator/base_generator"

module Cure
  module Generator
    class GuidGenerator < BaseGenerator
      private

      # @param [Object] _source_value
      def _generate(_source_value)
        SecureRandom.uuid.to_s
      end
    end
  end
end