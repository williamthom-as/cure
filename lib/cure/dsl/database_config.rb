# frozen_string_literal: true

require "cure/builder/base_builder"
require "cure/builder/candidate"

module Cure
  module Dsl
    class DatabaseConfig

      attr_reader :settings

      def initialize
        @settings = Settings.new(db_type: :in_memory)
      end

      def in_memory(options = {})
        # We will do something with this when we have actual options.. maybe PRAGMAs?
      end

      # @param [String] file_path
      # @param [TrueClass, FalseClass] drop_table_on_initialise - Do you want to clear out before starting?
      def persisted(file_path:, drop_table_on_initialise: false)
        @settings.file_path = file_path
        @settings.drop_table_on_initialise = drop_table_on_initialise
      end

      # In the future, we may need to break this out into in-memory and
      # file-based database configurations. For now, we can bundle it all
      # together.
      class Settings
        attr_reader :db_type

        attr_accessor :file_path, :drop_table_on_initialise

        # @param [Symbol] db_type - can be :in_memory or :file
        def initialize(db_type:)
          @db_type = db_type
        end
      end
    end
  end
end
