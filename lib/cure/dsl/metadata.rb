# frozen_string_literal: true

module Cure
  module Dsl
    class Metadata

      attr_reader :_name, :_version, :_comments, :_additional

      def initialize
        @_name = nil
        @_version = nil
        @_comments = nil
        @_additional = {}
      end

      def name(name)
        @_name = name
      end

      def version(version)
        @_version = version
      end

      def comments(comments)
        @_comments = comments
      end

      def additional(data: {})
        @_additional = data
      end
    end
  end
end
