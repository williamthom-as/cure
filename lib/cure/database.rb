# frozen_string_literal: true

require "sequel"
require "sqlite3"
require "singleton"

require "cure/config"

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
    include Cure::Configuration

    # @return [Sequel::SQLite::Database]
    attr_reader :database

    def initialize
      @database = init_database
      setup_db
    end

    def setup_db
      # Load this from config defined by user?
      @database.execute <<-SQL
        PRAGMA journal_mode = OFF;
        PRAGMA synchronous = 0;
        PRAGMA cache_size = 1000000;
        PRAGMA locking_mode = EXCLUSIVE;
        PRAGMA temp_store = MEMORY;",
      SQL
    end

    # App Service calls
    def find_variable(property_name)
      @database.from(:variables).where(name: property_name).get(:value)
    end

    # @param [Symbol,String] tbl_name
    # @param [Array] columns
    def create_table(tbl_name, columns, auto_increment: true)
      tbl_name = tbl_name.to_sym if tbl_name.class != Symbol

      @database.create_table tbl_name do
        primary_key :_id, auto_increment: auto_increment
        columns.each do |col_name|
          column col_name.to_sym, String
        end
      end
    end

    def with_transaction(&block)
      @database.transaction({}, &block)
    end

    # @param [Symbol,String] tbl_name
    # @return [TrueClass, FalseClass]
    def table_exist?(tbl_name)
      tbl_name = tbl_name.to_sym if tbl_name.class != Symbol

      @database.table_exists?(tbl_name)
    end
    alias table_exists? table_exist?

    # @param [Symbol,String] tbl_name
    # @param [Array<String>] row
    def insert_row(tbl_name, row)
      @database[tbl_name.to_sym].insert(row)
    end

    # @param [Symbol,String] tbl_name
    # @param [Array<String>] rows
    def insert_batched_rows(tbl_name, rows)
      @database[tbl_name.to_sym].import(@database[tbl_name.to_sym].columns, rows)
    end


    def add_column(tbl_name, new_column, default: "")
      tbl_name = tbl_name.to_sym if tbl_name.class != Symbol
      new_column = new_column.to_sym if new_column.class != Symbol

      @database.add_column(tbl_name, new_column, String, default:)
    end

    def remove_column(tbl_name, remove_column)
      tbl_name = tbl_name.to_sym if tbl_name.class != Symbol
      remove_column = remove_column.to_sym if remove_column.class != Symbol

      @database.drop_column tbl_name, remove_column
    end

    def list_columns(tbl_name)
      @database[tbl_name.to_sym].columns
    end

    def rename_column(tbl_name, old_column, new_column)
      tbl_name = tbl_name.to_sym if tbl_name.class != Symbol
      old_column = old_column.to_sym if old_column.class != Symbol
      new_column = new_column.to_sym if new_column.class != Symbol

      @database.rename_column tbl_name, old_column, new_column
    end

    def copy_column(tbl_name, from_column, to_column)
      tbl_name = tbl_name.to_sym if tbl_name.class != Symbol
      from_column = from_column.to_sym if from_column.class != Symbol
      to_column = to_column.to_sym if to_column.class != Symbol

      add_column tbl_name, to_column
      run("UPDATE #{tbl_name} SET #{to_column} = #{from_column}")
    end

    def run(query, opts={})
      @database.run(query, opts)
    end

    def with_paged_result(tbl_name, chunk_size: 100, &block)
      raise "No block given" unless block

      query = config.template.queries.find(tbl_name)
      if query
        @database[query.query].each do |row|
          block.yield row
        end
      else
        @database[tbl_name.to_sym].order(:_id).paged_each(rows_per_fetch: chunk_size, &block)
      end
    end

    def list_tables
      tbl_arr = @database.tables
      tbl_arr.delete(:variables)
      tbl_arr
    end

    private

    def init_database
      # Build from config
      # This must clean the database if its not in memory
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
