# frozen_string_literal: true

require "cure/cli/command"

# TODO: Generate script - inc File and init and Run export.

module Cure
  module Cli
    class GenerateCommand < Command
      def initialize(args)
        super(args)
      end

      def help(ex: nil)
        log_error ex.message if ex && ex.is_a?(StandardError)
        log_info "\nUsage: cure generate template [name]"
      end

      private

      def execute
        raise "You are not in a Cure project! Cannot create template." unless cure_project?

        log_info "Creating new template: #{params[:name]}\n"

        root_dir = File.join(Dir.pwd, "templates")
        make_file(root_dir, "#{params[:name]}_template.rb", template: "new_template.rb")
      end

      def validate
        # Theres a nicer way to do this, I'll do it later.
        raise ArgumentError, "Missing arguments" if @argv.empty?
        raise ArgumentError, "Invalid operation #{@argv.first}" if @argv.first != "template"
        raise ArgumentError, "Invalid name #{@argv.last}" if @argv.last.nil? || @argv.last.empty?
      end

      attr_reader :params

      def params
        {
          operation: @argv.first,
          name: @argv.last
        }
      end

      # Naive implementation, could do better. Who cares for now.
      # @return [TrueClass, FalseClass]
      def cure_project?
        gf = File.join(Dir.pwd, 'Gemfile')
        File.exist?(gf) && File.read(gf).include?('cure')
      end
    end
  end
end
