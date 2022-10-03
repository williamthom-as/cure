# frozen_string_literal: true

require "cure/log"
require "cure/helpers/file_helpers"
require "cure/config"
require "cure/extract/extractor"

require "rcsv"

module Cure
  module Builder

    class BaseBuilder
      def initialize(named_range, column, opts)
        @named_range = named_range
        @column = column
        @opts = opts
      end

      def process(_wrapped_csv)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class ExplodeBuilder < BaseBuilder

      # @param [Cure::Extract::WrappedCSV] wrapped_csv
      # @return [Cure::Extract::WrappedCSV]
      def process(wrapped_csv)
        content = wrapped_csv.find_named_range(@named_range)
        json_store, new_keys = extract_json_data(content)

        new_keys.each { |key| content.add_column_key(key) unless content.column_headers.key? key }

        content.rows.each_with_index do |row, idx|
          new_data = json_store[idx]
          new_keys.each do |key|
            row << new_data.fetch(key, "")
          end
        end

        wrapped_csv
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

        [temp_json_store, temp_new_keys]
      end
    end

    class AddBuilder < BaseBuilder

      # @param [Cure::Extract::WrappedCSV] wrapped_csv
      # @return [Cure::Extract::WrappedCSV]
      def process(wrapped_csv)
        content = wrapped_csv.find_named_range(@named_range)
        content.add_column_key(@column)

        content.rows.each { |row| row.append("") }

        wrapped_csv
      end
    end

    class RemoveBuilder < BaseBuilder

      # @param [Cure::Extract::WrappedCSV] wrapped_csv
      # @return [Cure::Extract::WrappedCSV]
      def process(wrapped_csv)
        content = wrapped_csv.find_named_range(@named_range)
        column_idx = content.column_headers.delete(@column)

        content.rows.each { |row| row.delete_at(column_idx) }

        wrapped_csv
      end
    end
  end
end
