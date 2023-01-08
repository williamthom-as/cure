# frozen_string_literal: true

require "cure"
require "json"
require "singleton"

module Cure
  module Configuration
    # @return [Config]
    def config
      conf = ConfigurationSource.instance.config
      raise "Set config first" unless conf

      conf
    end

    # @param [Cure::Configuration::CsvFileProxy] source_file
    # @param [Cure::Template] template
    # @return [Config]
    def create_config(source_file, template)
      Config.new(source_file, template)
    end

    # @param [Config] request_config
    def register_config(request_config)
      ConfigurationSource.instance.load_config(request_config)
    end

    # If we are overloading here as a "data store" and "config store", we
    # could break out variables and placeholders into their own singleton.
    #
    # This should be a kind of instance cache, which loads once per run,
    # and junk can be jammed in there?
    class Config

      # @return [Cure::Configuration::CsvFileProxy]
      attr_accessor :source_file

      # @return [Cure::Template]
      attr_accessor :template

      # @param [Cure::Configuration::CsvFileProxy] source_file
      # @param [Cure::Template] template
      def initialize(source_file, template)
        @source_file = source_file
        @template = template
      end

      def placeholders
        @template.transformations.placeholders || {}
      end
    end

    class ConfigurationSource
      include Singleton

      attr_reader :config

      # @param [Config] config
      # @return [Config]
      def load_config(config)
        @config = config
      end
    end

    class CsvFileProxy

      # @return [TrueClass,FalseClass]
      attr_reader :valid
      # @return [DefaultFileHandler]
      attr_reader :csv_handler

      # @return [CsvFileProxy]
      def self.load_file(type, obj)
        handler =
          case type
          when :file
            FileHandler.new(obj)
          when :file_contents
            FileContentsHandler.new(obj)
          when :pathname
            PathnameHandler.new(obj)
          else
            raise "Invalid file type handler [#{type}]"
          end

        new(handler)
      end

      # @return [DefaultFileHandler]
      def initialize(csv_handler)
        @csv_handler = csv_handler
      end

      def description
        @csv_handler.description
      end

      def with_file(&block)
        @csv_handler.with_file(&block)
      end
    end

    class DefaultFileHandler
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def with_file(&_block)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def description
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class PathnameHandler < DefaultFileHandler
      attr_accessor :pathname

      # @param [Pathname] pathname
      def initialize(pathname)
        super(:pathname)
        @pathname = pathname
      end

      def with_file(&_block)
        yield @pathname
      end

      def description
        @pathname.to_s
      end
    end

    class FileHandler < DefaultFileHandler
      # @return [File]
      attr_accessor :file

      # @param [File] file
      def initialize(file)
        super(:file)
        @file = file
      end

      def with_file(&_block)
        yield @file

        @file&.close
      end

      def description
        File.basename(file)
      end
    end

    class FileContentsHandler < DefaultFileHandler
      # @return [String]
      attr_accessor :file_contents

      # @param [String] file_contents
      def initialize(file_contents)
        super(:file_contents)
        @file_contents = file_contents
      end

      def with_file(&_block)
        yield @file_contents

        @file_contents&.close
      end

      def description
        "<content provided>"
      end
    end
  end
end
