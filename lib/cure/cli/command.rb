# frozen_string_literal: true

module Cure
  module Cli
    class Command

      # @param [String] command
      # @param [Array] argv
      def self.invoke(command, argv)
        case command
        when "new"
          NewCommand.new(argv).execute
        when "run"
          RunCommand.new(argv).execute
        else
          # Print help
        end
      end

      def initialize(argv)
        @argv = argv
      end

      def execute
        raise NotImplementedError
      end
    end

    class NewCommand < Command

      def initialize(argv)
        super(argv)
      end

      def execute
        puts "Creating new project: #{@argv[0]}"
      end
    end

    class RunCommand < Command
      def initialize(args)
        super(args)
      end

      def execute
        puts "Not implemented yet!"
      end
    end
  end
end
