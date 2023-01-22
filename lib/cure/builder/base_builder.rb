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

    class ExplodeBuilder < BaseBuilder

      # TODO: remove original column
      def process
        # content = wrapped_csv.find_named_range(@named_range)
        json_store, new_keys = extract_json_data(content)

        new_keys.each { |key| content.add_column_key(key) unless content.column_headers.key? key }

        content.rows.each_with_index do |row, idx|
          new_data = json_store[idx]
          new_keys.each do |key|
            row << new_data.fetch(key, "")
          end
        end
      end

      def safe_parse_json(candidate_str)
        candidate_str ||= "{}"
        JSON.parse(candidate_str)
      rescue StandardError
        {}
      end

      def extract_json_data(content)
        json_column_idx = content.column_headers[@column]

        temp_json_store = {}
        temp_new_keys = []
        content.rows.each_with_index do |row, idx|
          hash = safe_parse_json(row[json_column_idx])
          temp_json_store[idx] = hash
          hash.each_key do |key|
            temp_new_keys.push(key) unless temp_new_keys.include?(key)
          end
        end

        temp_new_keys = filter_keys(temp_new_keys)

        [temp_json_store, temp_new_keys]
      end

      #  rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
      def filter_keys(keys)
        filter_opts = @opts.fetch("filter", nil)
        return keys unless filter_opts

        type = filter_opts["type"]

        if type == "whitelist"
          candidates = filter_opts["values"]
          return keys.map { |k| candidates.include?(k) ? k : nil }&.compact
        end

        if type == "blacklist"
          candidates = filter_opts["values"]
          return keys.map { |k| candidates.include?(k) ? nil : k }&.compact
        end

        keys
      end
      #  rubocop:enable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity

      def to_s
        "Exploder Builder"
      end
    end

  end
end
