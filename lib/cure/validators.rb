# frozen_string_literal: true

module Cure
  module Validators
    # Should be an array, we can have multiple validators for the same obj
    @validators = {}

    class << self
      attr_accessor :validators

      # @param [String] prop
      # @param [Object] options
      def register_validator(caller, prop, options)
        @validators[caller] = [] unless @validators.has_key? caller
        @validators[caller] << {prop: "@#{prop}".to_sym, options:}
      end

      # @return [TrueClass, FalseClass]
      def validate(zelf) # rubocop:disable Metrics/AbcSize
        return true unless @validators.has_key? zelf.class

        variables = instance_variables_hash(zelf)
        @validators[zelf.class].all? do |k|
          options = k[:options]
          return true if options.empty? # No validator, no need to run.

          validator_prop = options[:validator]
          proc = case validator_prop
                 when Symbol
                   common_validators.fetch(validator_prop, proc { |_x| false })
                 # when Proc
                 #   validator_prop
                 else
                   proc { |_x| false }
                 end

          property = variables[k[:prop]]
          proc.call(property)
        end
      end

      # @param [Object] zelf
      # @return [Hash]
      def instance_variables_hash(zelf)
        zelf.instance_variables.each_with_object({}) do |attribute, hash|
          hash[attribute] = zelf.instance_variable_get(attribute)
        end
      end

      def common_validators
        {
          presence: proc { |current_val| !current_val.nil? }
        }
      end
    end

    def validates(property, options={})
      Validators.register_validator(self, property, options)
    end

    module Helpers
      def valid?(suppress_error: false)
        status = Validators.validate(self)
        return true if status
        return false if suppress_error

        raise "Object is invalid"
      end
    end
  end
end
