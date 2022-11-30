# frozen_string_literal: true

require "benchmark"

module Cure
  module Helpers
    # This module uses some code sourced from here:
    # https://torrocus.com/blog/different-ways-to-processing-large-csv-file-in-ruby/
    module PerfHelpers

      def print_memory_usage(process_name="default")
        cmd = "ps -o rss= -p #{Process.pid}"
        before_mem = `#{cmd}`.to_i
        before_gc = GC.stat(:total_allocated_objects)

        yield
        after_mem = `#{cmd}`.to_i
        after_gc = GC.stat(:total_allocated_objects)

        log_info "Total Memory Usage [#{process_name}]: #{((after_mem - before_mem) / 1024.0).round(2)} MB"
        log_info "Total GC Objects Freed [#{process_name}]: #{after_gc - before_gc}"
      end

      def print_time_spent(process_name="default", &block)
        time = Benchmark.realtime(&block)
        log_info "Total Processing Time [#{process_name}]: #{time.round(2)}"
      end

    end
  end
end
