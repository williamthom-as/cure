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

      def in_memory
        # We will do something with this when we have actual options.. maybe PRAGMAs?
      end

      # @param [String] file_path
      def persisted(file_path:)
        @settings.set_db_type(:file)

        @settings.file_path = file_path
      end

      # @param [TrueClass, FalseClass] value - Do you want to allow existing tables (good to merge two of the same file into one table)
      def allow_existing_table(value = false)
        @settings.allow_existing_table = value
      end

      # @param [TrueClass, FalseClass] value - Do you want to drop existing tables (good if new columns)
      def drop_table_on_initialise(value = false)
        @settings.drop_table_on_initialise = value
      end

      # @param [TrueClass, FalseClass] value - Do you want to clear out existing tables (good if same columns)
      def trunc_table_on_initialise(value = false)
        @settings.trunc_table_on_initialise = value
      end

      # @param [TrueClass, FalseClass] value - Do you want to clear out the translation table (good to force new translations)
      def trunc_translations_table_on_initialise(value = false)
        @settings.trunc_translations_table_on_initialise = value
      end

      # In the future, we may need to break this out into in-memory and
      # file-based database configurations. For now, we can bundle it all
      # together.
      class Settings
        attr_reader :db_type

        attr_accessor :file_path,
                      :allow_existing_table,
                      :drop_table_on_initialise,
                      :trunc_table_on_initialise,
                      :trunc_translations_table_on_initialise

        # @param [Symbol] db_type - can be :in_memory or :file
        def initialize(db_type:)
          @db_type = db_type
        end

        def set_db_type(db_type)
          @db_type = db_type
        end
      end
    end
  end
end
