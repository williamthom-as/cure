# frozen_string_literal: true

require "cure"
require "cure/log"

module Cure
  module Cli
    class Command
      include Log

      # @param [String] command
      # @param [Array] argv
      def self.invoke(command, argv)
        extend Log

        handler = nil

        case command
        when "new"
          handler = NewCommand.new(argv)
        when "generate"
            handler = GenerateCommand.new(argv)
        when "run"
          handler = RunCommand.new(argv)
        else
          new.help
          return
        end

        handler.call
      rescue ArgumentError => aex
        handler ? handler.help(ex: aex) : new.help
      rescue StandardError => ex
        log_error(ex.message)
      end

      # @param [Array] argv
      def initialize(argv = [])
        @argv = argv
      end

      def call
        validate
        execute
      end

      def help(ex: nil)
        log_error ex.message if ex && ex.is_a?(StandardError)
        log_error "Error: unknown request"
        log_info "\nUsage: cure <command> [options]"
        log_info "\tRun:         cure run -t [template] -f [file]"
        log_info "\tNew Project: cure new [name]"
      end

      private

      # @return [void]
      def execute
        raise NotImplementedError
      end

      # @return [void]
      # @raise [ArgumentError, NotImplementedError]
      def validate
        raise NotImplementedError
      end

      protected


      def make_directory(dir_name)
        log_info "Creating directory #{dir_name}"

        FileUtils.mkdir_p(dir_name)
      end

      def make_file(dir_name, file_name, template: nil, binding: nil)
        file = File.join(dir_name, file_name)

        log_info "Creating file #{file}"

        unless template
          FileUtils.touch(file)
          return
        end

        content = retrieve_template(template)
        if binding
          erb = ERB.new(content)
          content = erb.result_with_hash(binding)
        end

        File.open(file, "w") do |f|
          f.write(content)
        end
      end

      def retrieve_template(template)
        File.read(
          File.join(File.dirname(__FILE__), "templates", "#{template}.erb")
        )
      end
    end
  end
end
