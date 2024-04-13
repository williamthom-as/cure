# frozen_string_literal: true

# This will be a separate project in due time. For now, it can belong here.
# It allows the creation of a Cure Viz template that can be exported to JSON
# and loaded into the web app.
#
# Example:
#
# result = Cure::Viz::VizBase.new(title: "Test")
#   .with_description("This is a test")
#   .with_author("William")
#
#
# result.add_table_panel(title: "Test Table") do
#   columns(%w[Name Color Age City])
#   rows([
#      ["alice", "xanadu", 25, "New York"],
#      ["xavier", "azure", 30, "Los Angeles"],
#      ["emily", "emerald", 22, "Chicago"]
#   ])
# end
#
# result.add_chart_panel(title: "Test Chart", chart_type: Cure::Viz::WidgetTypes::BAR_CHART) do
#   labels(%w[Red Blue Yellow])
#   values([10, 20, 30])
#   options(
#     { chart_title: "Test Chart" }
#   )
# end
#
# Outputs file:
# result.export
#
module Cure
  module Viz
    class VizBase

      attr_reader :title, :description, :author, :panels

      # @param [String] title
      def initialize(title:)
        @title = title
        @panels = []
      end

      # @param [String] description
      def with_description(description)
        @description = description
        self
      end

      def with_author(author)
        @author = author
        self
      end

      def add_table_panel(title:, &block)
        panel = TableWidget.new(title: title)
        panel.instance_eval(&block)

        @panels << panel
        self
      end

      def add_chart_panel(title:, chart_type:, &block)
        panel = ChartWidget.new(title: title, widget_type: chart_type)
        panel.instance_eval(&block)

        @panels << panel
        self
      end

      def export
        self.to_h.to_json
      end

      def to_h
        # Seems ridiculous to have to do this... probably should handle more
        # object types but this works for now.
        instance_variables.each_with_object({}) do |var, hash|
          value = instance_variable_get(var)
          if value.is_a? Array
            value = value.map do |v|
              if v.respond_to?(:to_h)
                v.to_h
              else
                v
              end
            end
          end
          hash[var.to_s.delete('@')] = value
        end
      end
    end

    class BaseWidget

      attr_accessor :title, :widget_type, :data

      def initialize(title:, widget_type:)
        @title = title
        @widget_type = widget_type
        @data = {}
        @options = {}
      end

      # @param [String] width - full, or double.
      def with_width(width)
        @options[:width_class] = width
        self
      end

      def to_h
        instance_variables.each_with_object({}) do |var, hash|
          hash[var.to_s.delete('@')] = instance_variable_get(var)
        end
      end
    end

    class WidgetTypes
      BAR_CHART = "bar-chart"
      LINE_CHART = "line-chart"
      PIE_CHART = "pie-chart"
      TABLE = "table"
    end

    class TableWidget < BaseWidget

      def initialize(title:)
        super(title: title, widget_type: WidgetTypes::TABLE)
      end

      def rows(rows)
        @data[:rows] = rows
      end

      def columns(columns)
        @data[:columns] = columns
      end
    end

    class ChartWidget < BaseWidget
      def initialize(title:, widget_type:)
        super(title: title, widget_type: widget_type)
      end

      def labels(labels)
        @data[:labels] = labels
      end

      def values(values)
        @data[:values] = values
      end

      def options(options)
        @data[:options] = options
      end
    end
  end
end
