# frozen_string_literal: true

require "cure"
require "json"

module Cure
  module Helpers
    module ObjectHelpers
      def class_exists?(klass_name)
        klass = Module.const_get(klass_name)
        klass.is_a?(Class)
      rescue NameError
        false
      end
    end
  end
end
