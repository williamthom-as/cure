# frozen_string_literal: true

require "cure/database"

# Singleton Strategy for storing data across all processes

module Cure
  module History

    # @return [HistoryCache]
    def history
      HistoryCache.instance
    end

    # @return [String]
    def retrieve_history(source_value)
      history.search(source_value) unless source_value.nil? || source_value == ""
    end

    # @param [String] source_value
    # @param [String] value
    def store_history(source_value, value)
      unless source_value.nil? || source_value == ""
        history.insert(source_value, value)
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
        return if database_service.table_exist?(:translations)

        database_service.create_table(:translations, %w[source_value value named_range column])
      end

      # @return [String]
      def search(source_value, _named_range: nil, _column: nil)
        database_service.find_translation(source_value)
      end

      def insert(source_value, value, named_range: nil, column: nil)
        @count += 1

        database_service.insert_row(:translations, [
          @count, source_value, value, named_range, column
        ])
      end

      def all_values
        database_service.all_translations
      end

      def reset
        @count = 0

        database_service.truncate_table(:translations)
      end

      def table_count
        database_service.table_count(:translations)
      end
    end
  end
end
