# frozen_string_literal: true

require "cure/generator/base_generator"
require "faker"

module Cure
  module Generator
    class FakerGenerator < BaseGenerator
      private

      # @param [Object] _source_value
      # @param [RowCtx] _row_ctx
      def _generate(_source_value, _row_ctx)
        mod_code = extract_property("module", nil)
        mod = Faker.const_get(mod_code)

        raise "No Faker module found for [#{mod_code}]" unless mod

        meth_code = extract_property("method", nil)&.to_sym
        raise "No Faker module found for [#{meth_code}]" unless mod.methods.include?(meth_code)

        mod.send(meth_code)
      end
    end
  end
end
