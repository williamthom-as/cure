# frozen_string_literal: true

require "fileutils"
require "benchmark"

module Cure
  module Helpers
    # This module uses code sourced from here:
    # https://torrocus.com/blog/different-ways-to-processing-large-csv-file-in-ruby/
    module PerfHelpers

      def print_memory_usage(process_name="default")
        cmd = "ps -o rss= -p #{Process.pid}"
        before = `#{cmd}`.to_i
        yield
        after = `#{cmd}`.to_i
        log_info "Total Memory Usage [#{process_name}]: #{((after - before) / 1024.0).round(2)} MB"
      end

      def print_time_spent(process_name="default", &block)
        time = Benchmark.realtime(&block)
        log_info "Total Processing Time [#{process_name}]: #{time.round(2)}"
      end

    end
  end
end
