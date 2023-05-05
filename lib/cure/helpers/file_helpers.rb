# frozen_string_literal: true

require "fileutils"
require "pathname"

module Cure
  module Helpers
    module FileHelpers
      def with_file(path, extension, &block)
        dir = File.dirname(path)

        FileUtils.mkdir_p(dir) unless File.directory?(dir)

        path = "#{path}.#{extension}"
        File.open(path, "w", &block)
      end

      def clean_dir(path)
        dir = File.file?(path) ? File.dirname(path) : path

        FileUtils.remove_dir(dir) if File.directory?(dir)
      end

      def read_file(file_location)
        result = file_location.start_with?("/") ? file_location : Pathname.new(file_location)
        # result = file_location.start_with?("/") ? file_location : File.join(File.dirname(__FILE__), file_location)

        raise "No file found at [#{file_location}]" unless File.exist? result.to_s

        File.read(result)
      end

      def open_file(file_location)
        result = file_location.start_with?("/") ? file_location : Pathname.new(file_location)

        raise "No file found at [#{file_location}]" unless File.exist? result.to_s

        File.open(result)
      end

      def with_temp_dir(temp_dir, &_block)
        return unless block_given?

        clean_dir(temp_dir)
        yield
        clean_dir(temp_dir)
      end
    end
  end
end
