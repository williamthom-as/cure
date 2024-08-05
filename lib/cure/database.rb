# frozen_string_literal: true

require "sequel"
require "sqlite3"
require "singleton"

require "cure/config"

module Cure
  module Database
    def database_service
      database = DatabaseSource.instance.database_service
      return database if database

      init_database

      DatabaseSource.instance.database_service
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

    # @return [Cure::Dsl::DatabaseConfig::Settings]
    attr_reader :settings

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
        PRAGMA temp_store = MEMORY;
      SQL
    end

    # App Service calls
    def find_variable(property_name)
      @database.from(:variables).where(name: property_name).get(:value)
    end

    def find_translation(source_value)
      @database.from(:translations).where(source_value: source_value).get(:value)
    end

    def all_translations
      @database.from(:translations).all
    end

    # @param [Symbol,String] tbl_name
    # @param [Array] columns
    def create_table(tbl_name, columns, auto_increment: true)
      tbl_name = tbl_name.to_sym if tbl_name.class != Symbol

      if table_exist?(tbl_name)
        unless @settings.allow_existing_table
          raise "Table already exists: #{tbl_name}. Use named ranges if you want different tables" /
                  " or set allow_existing_table to true."
        end

        if @settings.drop_table_on_initialise
          drop_table(tbl_name)
        elsif @settings.trunc_table_on_initialise
          truncate_table(tbl_name)
        end

        return
      end

      @database.create_table tbl_name do
        primary_key :_id, auto_increment: auto_increment
        columns.each do |col_name|
          column col_name.to_sym, String
        end
      end
    end

    # @param [Symbol,String] tbl_name
    def drop_table(tbl_name)
      @database[tbl_name.to_sym].truncate
    end

    # @param [Symbol,String] tbl_name
    def truncate_table(tbl_name)
      @database[tbl_name.to_sym].truncate
    end

    # @param [Symbol,String] tbl_name
    def table_count(tbl_name)
      @database[tbl_name.to_sym].count
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
    def insert_row(tbl_name, row, columns: nil)
      unless columns
        columns = @database[tbl_name.to_sym].columns
        columns.delete(:_id)
      end

      @database[tbl_name.to_sym].insert(columns, row)
    end

    # @param [Symbol,String] tbl_name
    # @param [Array<String>] rows
    def insert_batched_rows(tbl_name, rows, columns: nil)
      unless columns
        columns = @database[tbl_name.to_sym].columns
        columns.delete(:_id)
      end

      @database[tbl_name.to_sym].import(columns, rows)
    end

    def add_column(tbl_name, new_column, default: "")
      tbl_name = tbl_name.to_sym if tbl_name.class != Symbol
      new_column = new_column.to_sym if new_column.class != Symbol

      @database.add_column(tbl_name, new_column, String, default: default)
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

    # Can we decouple query from named range? Probably more difficult
    # than it seems. But would be nice to create two queries that doesn't
    # require two tables (named ranges).
    def with_paged_result(tbl_name, chunk_size: 100, &block)
      raise "No block given" unless block

      query = config.template.queries.find(tbl_name)
      if query
        query_str = query.query#.strip.chomp(";") # sequel can't end in ;, but its natural to add it incidentally.
        @database[query_str].order(:_id).paged_each(rows_per_fetch: chunk_size, &block)
      else
        @database[tbl_name.to_sym].order(:_id).paged_each(rows_per_fetch: chunk_size, &block)
      end
    rescue Sequel::DatabaseError, SQLite3::SQLException => e
      resolve_msg = "Error attempting to query table: #{tbl_name}. Please check your query."
      raise "#{resolve_msg} Error: #{e.message}"
    end

    def list_tables
      tbl_arr = @database.tables
      tbl_arr.delete(:variables)

      if tbl_arr.include?(:translations)
        tbl_arr.delete(:translations)
        tbl_arr.push(:translations)
      end

      tbl_arr
    end

    private

    def init_database
      # Build from config
      # This must clean the database if its not in memory
      @settings = config.template.database_config.settings

      if @settings.db_type == :in_memory
        Sequel.connect("sqlite:/")
      else
        # File-based path
        raise "Please set file path for persisted database" unless settings.file_path

        full_file_path = File.expand_path(settings.file_path)
        Sequel.connect("sqlite://#{full_file_path}")
      end
    end
  end
end
