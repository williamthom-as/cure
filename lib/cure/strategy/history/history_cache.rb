# frozen_string_literal: true

require "cure/database"

# Singleton Strategy for storing data across all processes

module Cure
  module History

    # @return [HistoryCache]
    def history
      HistoryCache.instance
    end

    # @param [String, nil] _source_column
    # @param [String, nil] source_value
    # @return [String]
    def retrieve_history(_source_column, source_value, from_columns: [])
      return if source_value.nil? || source_value == ""

      history.search(source_value, from_columns: from_columns)
    end

    # @param [String, nil] source_column
    # @param [String, nil] source_value
    # @param [String, nil] generated_value
    def store_history(source_column, source_value, generated_value)
      unless source_value.nil? || source_value == ""
        history.insert(source_value, generated_value, column: source_column)
      end
    end

    def reset_history
      history.reset
    end
    alias clear_history reset_history

    class HistoryCache
      include Database
      include Singleton

      attr_accessor :count

      def initialize
        @count = 0

        init_cache
      end

      # @return [String]
      def search(source_value, _named_range: nil, from_columns: nil)
        database_service.find_translation(source_value, from_columns: from_columns)
      end

      def insert(source_value, value, named_range: nil, column: nil)
        @count += 1

        # ID Changes here.
        database_service.insert_row(
          :translations,
          [source_value, value, named_range, column],
          columns: %w[source_value value named_range column]
        )
      end

      def all_values
        database_service.all_translations
      end

      def reset
        @count = 0

        if database_service.table_exist?(:translations)
          # Need to think about this ... what should be the default action... for now:

          if database_service.settings.trunc_translations_table_on_initialise
            database_service.truncate_table(:translations)
          end
        else
          init_cache
        end
      end

      def table_count
        database_service.table_count(:translations)
      end

      def init_cache
        return if database_service.table_exist?(:translations)

        database_service.create_table(:translations, %w[source_value value named_range column])
      end
    end
  end
end
