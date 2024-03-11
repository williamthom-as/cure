# frozen_string_literal: true

module Cure
  # This file is used as part of the external project interface
  # and not part of a regular Cure workflow.
  class BaseRunner

    def perform
      handler = Cure.init_from_file(template_path)

      with_files do |file|
        handler.process(:path, file)
      end
    end

    private

    def template_path
      "templates/#{prefix}_template.rb"
    end

    def with_files(&block)
      Dir.glob("input/#{prefix}/*", &block)
    end

    def prefix
      # We can do this better later.
      @prefix ||= self.class.name
        .gsub("Runner", "")
        .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        .gsub(/([a-z\d])([A-Z])/,'\1_\2')
        .tr("-", "_")
        .downcase
    end
  end
end
