# frozen_string_literal: true

require "cure/log"
require "cure/config"

module Cure
  class Planner
    include Configuration
    include Log

    def process
      print_starter
      print_extract_plan
      print_build_plan
      print_transformations_plan
    end

    def print_starter
      print_title("Cure Execution Plan")
      log_info "Source file location: #{config.source_file.path}"
      log_info "Template file descriptor below"

      print_spacer
    end

    def print_extract_plan # rubocop:disable Metrics/AbcSize
      print_title "Extract"
      named_ranges = config.template.extraction.named_ranges
      variables = config.template.extraction.variables

      if named_ranges.size.zero?
        print_empty(named_ranges, "If you wanted to add a named range, please read docs/extraction.md")
      else
        log_info("[#{named_ranges.length}] named ranges specified")
        named_ranges.each do |nr|
          log_info "-- #{nr["name"]} will extract values from #{nr["section"]}"
        end
      end

      print_spacer

      if variables.size.zero?
        print_empty("variables")
      else
        log_info("[#{variables.length}] variables specified")
        variables.each do |v|
          log_info "-- #{v["name"]} will extract #{v["type"]} from #{v["location"]}"
        end
      end

      print_spacer
    end

    def print_build_plan
      print_title "Build"
      candidates = config.template.build.candidates

      if candidates.size.zero?
        print_empty("Build")
      else
        candidates.each do |c|
          log_info "-- #{c.column} from #{c.named_range} will be changed with #{c.action}"
        end
      end

      print_spacer
    end

    def print_transformations_plan # rubocop:disable Metrics/AbcSize
      print_title "Transforms"
      candidates = config.template.transformations.candidates
      placeholders = config.template.transformations.placeholders

      if candidates.size.zero?
        print_empty("Transforms")
      else
        candidates.each do |c|
          log_info "-- #{c.column} from #{c.named_range} will be changed with #{c.translations.size} translation"
          c.translations.each do |tr|
            log_info "\t -- Replacement: #{tr.strategy.class}, Generator: #{tr.generator.class}"
          end
        end
      end

      print_spacer

      if placeholders.values.size.zero?
        print_empty("Placeholders")
      else
        placeholders.each do |k, v|
          log_info "-- #{k} => #{v}"
        end
      end
    end

    private

    def print_title(title)
      log_info title
      log_info "====="
      print_spacer
    end

    def print_empty(descriptor, remedy=nil)
      log_info("No #{descriptor} specified.")
      log_info "[Remedy: #{remedy}]" unless remedy.nil?
    end

    def print_spacer
      log_info ""
    end
  end
end
