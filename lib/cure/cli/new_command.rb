# frozen_string_literal: true

require "cure/version"
require "cure/cli/command"

require "fileutils"
require "erb"

module Cure
  module Cli
    class NewCommand < Command
      def initialize(argv)
        super(argv)
      end

      def help(ex: nil)
        log_error ex.message if ex && ex.is_a?(StandardError)
        log_info "\nUsage: cure new [name]"
      end

      private

      def execute
        root_dir = File.join(Dir.pwd, @argv[0])

        raise "Project already exists in directory!" if File.exist?(root_dir)

        log_info "Creating new project: #{@argv[0]}"

        make_directory(root_dir)
        make_directory(File.join(root_dir, "input"))
        make_directory(File.join(root_dir, "output"))
        make_directory(File.join(root_dir, "scripts"))
        make_directory(File.join(root_dir, "templates"))
        make_directory(File.join(root_dir, "utilities"))
        make_directory(File.join(root_dir, "runners"))

        make_file(root_dir, ".gitignore", template: "gitignore")
        make_file(root_dir, ".tool-versions", template: "tool-versions")
        make_file(root_dir, "README.md", template: "README.md")
        make_file(root_dir, "Gemfile", template: "gemfile", binding: { version: Cure::VERSION })
        make_file("#{root_dir}/input", ".gitkeep")
        make_file("#{root_dir}/output", ".gitkeep")
        make_file(root_dir, "main.rb")
      end

      # @return [void]
      # @raise [ArgumentError]
      def validate
        raise ArgumentError, "Error: No project name given" if @argv.empty?
      end
    end
  end
end
