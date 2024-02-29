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

        log_info "Creating new project: #{@argv[0]}\n"

        make_directory(root_dir)
        make_directory(File.join(root_dir, "input"))
        make_directory(File.join(root_dir, "output"))
        make_directory(File.join(root_dir, "scripts"))
        make_directory(File.join(root_dir, "templates"))
        make_directory(File.join(root_dir, "utilities"))

        make_file(root_dir, ".gitignore", template: "gitignore")
        make_file(root_dir, ".tool-versions", template: "tool-versions")
        make_file(root_dir, "README.md", template: "README.md")
        make_file(root_dir, "Gemfile", template: "gemfile", binding: { version: Cure::VERSION })
        make_file("#{root_dir}/input", ".gitkeep")
        make_file("#{root_dir}/output", ".gitkeep")
      end

      # @return [void]
      # @raise [ArgumentError]
      def validate
        raise ArgumentError, "Error: No project name given" if @argv.empty?
      end

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
