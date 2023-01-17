# frozen_string_literal: true

module Cure
  module Dsl
    class Template
      def initialize(dsl_source, identifier, line_number=1)
        @proc = Binding.get.eval(<<-SOURCE, identifier, line_number)
          Proc.new do
            #{dsl_source}
          end
        SOURCE
      end

      def generate(instance_variables={})
        dsl = Cure::Dsl::DslHandler.new
        instance_variables.each do |name, value|
          dsl.instance_variable_set("@#{name}", value)
        end

        dsl.instance_eval(&@proc)

        dsl
      end
    end

    module Binding
      # @return [Object] Empty object for binding purposes
      def self.get
        binding
      end
    end

    class DslHandler
      def initialize
        @template = nil
      end

      def csv(properties={})
        puts properties
      end

      def extraction(&block)
        Extraction.from_block(&block)
      end
    end

    class Extraction
      def self.from_block(instance_variables={}, &block)
        extract = Extraction.new
        extract.instance_eval(&block)
      end

      def initialize
        @named_ranges = []
        @variables = []
      end

      def named_ranges(&block)
        @named_ranges << Section.from_block(&block)
        puts @named_ranges
      end
    end

    class Section

      attr_accessor :name, :at

      def self.from_block(instance_variables={}, &block)
        section = Section.new
        section.instance_eval(&block)
      end

      def section(args)
        puts "#{args}"
      end

    end
  end
end

