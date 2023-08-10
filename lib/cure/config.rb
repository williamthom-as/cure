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
    def create_config(source_files, template)
      Config.new(source_files, template)
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

      # @return Array<Cure::Configuration::CsvFileProxy>
      attr_accessor :source_files

      # @return [Cure::Template]
      attr_accessor :template

      # @param [Cure::Configuration::CsvFileProxy] source_files
      # @param [Cure::Template] template
      def initialize(source_files, template)
        @source_files = source_files
        @template = template
      end

      def placeholders
        @template.transformations.placeholders || {}
      end

      def with_source_file(&block)
        @source_files.each_with_index do |file, _idx|
          file.with_file(&block)
        end
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
      def self.load_file(type, obj, ref_name)
        handler =
          case type
          when :file
            FileHandler.new(obj, ref_name)
          when :file_contents
            FileContentsHandler.new(obj, ref_name)
          when :path, :pathname
            PathnameHandler.new(obj, ref_name)
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
      attr_reader :type, :ref_name

      def initialize(type, ref_name)
        @type = type
        @ref_name = ref_name
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
      def initialize(pathname, ref_name)
        super(:pathname, ref_name)
        @pathname = pathname
      end

      def with_file(&_block)
        yield @pathname, @ref_name
      end

      def description
        @pathname.to_s
      end
    end

    class FileHandler < DefaultFileHandler
      # @return [File]
      attr_accessor :file

      # @param [File] file
      def initialize(file, ref_name)
        super(:file, ref_name)
        @file = file
      end

      def with_file(&_block)
        yield @file, @ref_name

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
      def initialize(file_contents, ref_name)
        super(:file_contents, ref_name)
        @file_contents = file_contents
      end

      def with_file(&_block)
        yield @file_contents, @ref_name

        @file_contents&.close
      end

      def description
        "<content provided>"
      end
    end
  end
end
