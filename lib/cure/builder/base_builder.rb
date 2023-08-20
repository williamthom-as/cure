# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/database"
require "cure/helpers/file_helpers"
require "cure/extract/extractor"

require "rcsv"

module Cure
  module Builder
    include Database

    class BaseBuilder
      include Database

      def initialize(named_range, column, opts)
        @named_range = named_range
        @column = column
        @opts = opts
      end

      def process
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def to_s
        "Base Builder"
      end

      def with_database(&block)
        raise "Missing block" unless block

        yield database_service
      end
    end

    class AddBuilder < BaseBuilder

      def process
        with_database do |db_svc|
          db_svc.add_column(@named_range.to_sym, @column.to_sym, default: @opts.fetch(:default_value, nil))
        end
      end

      def to_s
        "Add Builder"
      end
    end

    class RemoveBuilder < BaseBuilder

      def process
        with_database do |db_svc|
          db_svc.remove_column(@named_range.to_sym, @column.to_sym)
        end
      end

      def to_s
        "Remove Builder"
      end
    end

    class RenameBuilder < BaseBuilder

      def process
        with_database do |db_svc|
          db_svc.rename_column(@named_range.to_sym, @column.to_sym, @opts.fetch("new_name"))
        end
      end

      def to_s
        "Rename Builder"
      end
    end

    class CopyBuilder < BaseBuilder

      def process
        with_database do |db_svc|
          db_svc.copy_column(@named_range.to_sym, @column.to_sym, @opts.fetch("to_column"))
        end
      end

      def to_s
        "Copy Builder"
      end
    end

    class BlacklistBuilder < BaseBuilder
      def process
        @opts[:columns].each do |column|
          with_database do |db_svc|
            db_svc.remove_column(@named_range.to_sym, column.to_sym)
          end
        end
      end

      def to_s
        "Blacklist builder"
      end
    end

    class WhitelistBuilder < BaseBuilder
      def process
        with_database do |db_svc|
          whitelist_columns = (@opts[:columns]).map(&:to_sym)
          all_columns = db_svc.list_columns(@named_range.to_sym)

          # Remove cols that aren't defined in white list or sys columns
          candidate_cols = all_columns - whitelist_columns - [:_id]

          candidate_cols.each do |column|
            db_svc.remove_column(@named_range.to_sym, column.to_sym)
          end
        end
      end

      def to_s
        "Whitelist builder"
      end
    end
  end
end
