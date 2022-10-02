# frozen_string_literal: true

require "cure/log"
require "cure/helpers/file_helpers"
require "cure/config"
require "cure/extract/extractor"

require "rcsv"

module Cure
  module Builder

    class BaseBuilder
      def initialize(opts)
        @named_range = opts.fetch("named_range", "default")
        @column = opts["column"]
        @opts = opts["action"]["options"]
      end

      def process(_wrapped_csv)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class ExploderBuilder < BaseBuilder

      # @param [Cure::Extract::WrappedCSV] wrapped_csv
      def process(wrapped_csv)
        content = wrapped_csv.find_named_range(@named_range)
        json_column_idx = content.column_headers[@column]

        content.rows.each do |row|
          hash = safe_parse_json(row[json_column_idx])
          hash.each_key do |key|
          end
        end
      end

      def safe_parse_json(candidate_str)
        candidate_str ||= "{}"
        JSON.parse(candidate_str)
      rescue StandardError
        {}
      end
    end
  end
end