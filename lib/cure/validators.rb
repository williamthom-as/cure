# frozen_string_literal: true

module Cure
  module Validators

    # Should be an array, we can have multiple validators for the same obj
    @validators = {}

    class << self
      attr_accessor :validators

      # @param [String] prop
      # @param [Object] validator
      def register_validator(caller, prop, validator)
        @validators[caller] = [] unless @validators.has_key? caller
        @validators[caller] << {prop: "@#{prop}".to_sym, validator: validator}
      end

      # @return [TrueClass, FalseClass]
      def validate(zelf)
        return true unless @validators.has_key? zelf.class

        variables = instance_variables_hash(zelf)
        @validators[zelf.class].all? { |k| variables[k[:prop]] } # actually run validation
      end

      # @param [Object] zelf
      # @return [Hash]
      def instance_variables_hash(zelf)
        zelf.instance_variables.each_with_object({}) do |attribute, hash|
          hash[attribute] = zelf.instance_variable_get(attribute)
        end
      end
    end

    def validates(property, *args)
      Validators.register_validator(self, property, {})
    end

    def each_validator(&block)
      @validators.each(&block)
    end

    module Helpers

      def valid?
        Validators.validate(self)
      end
    end
  end
end
