# frozen_string_literal: true

require "fileutils"

module Cure
  module FileHelpers

    def with_file(path, extension, &block)
      dir = File.dirname(path)

      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      path << ".#{extension}"
      File.open(path, "w", &block)
    end

    def clean_dir(path)
      dir = File.dirname(path)

      FileUtils.rm_f(dir) if File.directory?(dir)
    end

    def read_file(file_location)
      result = file_location.start_with?("/") ? file_location : File.join(File.dirname(__FILE__), file_location)

      raise "No file found at [#{file_location}]" unless File.exist? result

      File.read(result)
    end

  end
end
