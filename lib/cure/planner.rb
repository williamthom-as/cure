# frozen_string_literal: true

require "cure/log"
require "cure/config"
require "cure/helpers/string"

require "artii"

module Cure
  class Planner
    include Configuration
    include Log

    def process
      print_starter
      print_extract_plan
      print_build_plan
      print_transformations_plan
      print_ender
    end

    def print_starter # rubocop:disable Metrics/AbcSize
      a = Artii::Base.new({font: "isometric1"})
      puts a.asciify("C u r e")
      puts "\nIf you require assistance, please read:"
      puts "https://github.com/williamthom-as/cure/tree/main/docs\n"
      puts ""
      log_info "_______________________________________________"
      print_spacer
      log_info "Cure Execution Plan".bold.underline
      log_info ""
      log_info "Source file location: #{config.source_file.description}"
      log_info "Template file descriptor below"

      print_spacer
    end

    def print_ender
      log_info "_______________________________________________"
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
          log_info "-- #{nr.name} will extract values from #{nr.section}"
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

    def print_transformations_plan # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity
      print_title "Transforms"
      candidates = config.template.transformations.candidates
      placeholders = config.template.transformations.placeholders

      if candidates.size.zero?
        print_empty("Transforms")
      else
        candidates.each do |c|
          log_info "-- #{c.column} from #{c.named_range} will be changed with #{c.translations.size} translation"
          c.translations.each do |tr|
            log_info "\t\t> #{"Replacement".bold} [#{tr.strategy.class}]: #{tr.strategy.describe}"
            log_info "\t\t> #{"Generator".bold} [#{tr.generator.class}]: #{tr.generator.describe}"
          end
        end
      end

      print_spacer

      if placeholders.nil? || placeholders.size.zero?
        print_empty("Placeholders")
      else
        log_info "-- Variables"
        placeholders.each do |k, v|
          log_info "\t\t> #{k} => #{v}"
        end
      end

      print_spacer
    end

    private

    def print_title(title)
      log_info title.bold.underline
      print_spacer
    end

    def print_empty(descriptor, remedy=nil)
      log_info "No #{descriptor} specified.".italic
      log_info "[Remedy: #{remedy}]" unless remedy.nil?
    end

    def print_spacer
      log_info ""
    end
  end
end
