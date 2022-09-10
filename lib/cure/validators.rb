# frozen_string_literal: true

module Cure
  module Validators

    # Should be an array, we can have multiple validators for the same obj
    @validators = {}

    class << self
      attr_accessor :validators

      # @param [String] prop
      # @param [Object] validator
      def register_validator(prop, validator)
        @validators[prop.to_sym] = validator
      end

      # @param [Object] thiz
      # @return [TrueClass, FalseClass]
      def obj_is_valid?(thiz)
        variables = instance_variables_hash(thiz)
        @validators.all? { |k, _v| variables[k] }
      end

      # @param [Object] thiz
      # @return [Hash]
      def instance_variables_hash(thiz)
        thiz.instance_variables.each_with_object({}) do |attribute, hash|
          hash[attribute] = thiz.instance_variable_get(attribute)
        end
      end
    end

    def validates(property, *args)
      Validators.register_validator(property, {})
    end

    def each_validator(&block)
      @validators.each(&block)
    end

    module Helpers

      def valid?
        Validators.obj_is_valid?(self)
      end
    end
  end
end
