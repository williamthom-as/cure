# frozen_string_literal: true

# require "cure/config"
require "sequel"
require "sqlite3"

class DatabaseService
  # include Cure::Configuration

  def initialize
    @database = init_database
  end

  # @param [Symbol,String] tbl_name
  # @param [Array] columns
  def create_table(tbl_name, columns)
    @database.create_table tbl_name.to_sym do
      primary_key :id
      columns.each do |col_name|
        column col_name.to_sym, String
      end
    end
  end

  # @param [Symbol,String] tbl_name
  # @param [Hash<String,String>] row_hash
  def insert_row(tbl_name, row_hash)
    @database[tbl_name.to_sym].insert(row_hash)
  end

  def with_paged_result(tbl_name, chunk_size: 100, &block)
    raise "No block given" unless block

    @database[tbl_name.to_sym].order(:id).paged_each(rows_per_fetch: chunk_size, &block)
  end

  private

  def init_database
    Sequel.connect("sqlite:/")
  end
end

# db = DatabaseService.new
# db.create_table(:test, %w[name age])
# db.insert_row(:test, {name: "abc"})
# db.with_paged_result(:test) do |row|
#   puts row
# end

