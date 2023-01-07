# frozen_string_literal: true

require "sequel"
require "sqlite3"
require "singleton"

# require "cure/config"

module Cure
  module Database

    def database_service
      database = DatabaseSource.instance.database_service
      raise "Init database first" unless database

      database
    end

    def init_database
      DatabaseSource.instance.init_database
    end
  end

  class DatabaseSource
    include Singleton

    attr_reader :database_service

    def init_database
      @database_service = DatabaseService.new
    end
  end

  class DatabaseService
    # include Cure::Configuration

    # @return [Sequel::SQLite::Database]
    attr_reader :database

    def initialize
      @database = init_database
      @tables = []
    end

    # @param [Symbol,String] tbl_name
    # @param [Array] columns
    def create_table(tbl_name, columns)
      tbl_name = tbl_name.to_sym if tbl_name.class != Symbol

      @database.create_table tbl_name do
        primary_key :id
        columns.each do |col_name|
          column col_name.to_sym, String
        end
      end

      @tables << tbl_name
    end

    # @param [Symbol,String] tbl_name
    # @return [TrueClass, FalseClass]
    def table_exist?(tbl_name)
      @tables.include?(tbl_name)
    end

    # @param [Symbol,String] tbl_name
    # @param [Array<String>] row
    def insert_row(tbl_name, row)
      @database[tbl_name.to_sym].insert(row)
    end

    def with_paged_result(tbl_name, chunk_size: 100, &block)
      raise "No block given" unless block

      @database[tbl_name.to_sym].order(:id).paged_each(rows_per_fetch: chunk_size, &block)
    end

    private

    def init_database
      # Build from config
      Sequel.connect("sqlite:/")
    end
  end
end

# db = Cure::DatabaseService.new
# db.create_table(:test, %w[name age])
# db.insert_row(:test, {name: "abc"})
# db.with_paged_result(:test) do |row|
#   puts row
# end

