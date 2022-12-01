# frozen_string_literal: true

require "cure"
require "singleton"
require "sequel"
require "cure/log"

module Cure
  module Database

    # @return [Cure::Database::DatabaseService]
    def instance
      DatabaseSource.instance.database_instance
    end

    def create_instance
      DatabaseSource.instance.load_instance
    end

    class DatabaseSource
      include Singleton

      # @return [Cure::Database::DatabaseService]
      attr_reader :database_instance

      def load_instance
        @database_instance = DatabaseService.new
      end
    end

    class DatabaseService
      include Log

      attr_accessor :database

      def initialize
        @database = create_instance
      end

      # @return [Sequel::SQLite::Database] database_instance
      def create_instance
        # This should look at config for a impl
        @database = Sequel.sqlite
      end
      alias reset create_instance

      def create_table(name, columns)
        @database.run(
          "CREATE TABLE #{name} (#{columns.map { |column| "#{column} text" }})"
        )
      rescue StandardError => e
        log_error("Error creating table", e)
        raise e
      end

      def insert_record

      end
    end
  end
end
