# frozen_string_literal: true

module Cure
  module Cleanup
    class Extractor

      # @param [Hash] opts
      attr_reader :opts

      # @param [Hash] opts
      def initialize(opts)
        @opts = opts
      end

      def extract(csv); end
    end
  end
end
